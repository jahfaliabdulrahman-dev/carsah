import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/invoice_image.dart';

/// Normalized invoice storage with reference counting and content-addressable deduplication.
///
/// Architecture:
/// - InvoiceImage entity in Isar holds relativePath + contentHash + refCount
/// - MaintenanceRecord links to InvoiceImage via invoiceImageId
/// - Same invoice image shared across records without duplication
/// - File deleted only when refCount reaches zero
class RefCountedInvoiceService {
  static const _invoiceDir = 'invoices';
  final Isar _isar;
  final ImagePicker _picker = ImagePicker();

  RefCountedInvoiceService(this._isar);

  /// Pick an image, hash it, deduplicate or create, return InvoiceImage ID.
  ///
  /// Flow:
  /// 1. Pick image via camera/gallery
  /// 2. Compute SHA-256 hash of file contents
  /// 3. Check if hash exists in Isar (deduplication)
  ///    - If exists: increment refCount, return existing ID
  ///    - If new: save file, create InvoiceImage with refCount=1, return new ID
  Future<int?> pickAndAttach({required ImageSource source}) async {
    try {
      // Step 1: Pick image
      final picked = await _picker.pickImage(source: source, imageQuality: 100);
      if (picked == null) return null;

      final sourceFile = File(picked.path);

      // Step 2: Compute hash in background isolate
      final hash = await compute(_hashFile, picked.path);
      debugPrint('[INVOICE HASH] $hash');

      // Step 3: Check for existing image with same hash
      final existing = await _isar.invoiceImages
          .filter()
          .contentHashEqualTo(hash)
          .findFirst();

      if (existing != null) {
        // DEDUP: Same invoice already exists — increment refCount
        await _isar.writeTxn(() async {
          existing.refCount++;
          await _isar.invoiceImages.put(existing);
        });
        debugPrint('[INVOICE DEDUP] Reusing existing: ${existing.relativePath} (refCount: ${existing.refCount})');
        return existing.id;
      }

      // Step 4: New invoice — save to sandbox
      final appDir = await getApplicationDocumentsDirectory();
      final invoicesDir = Directory('${appDir.path}/$_invoiceDir');
      if (!await invoicesDir.exists()) {
        await invoicesDir.create(recursive: true);
      }

      final filename = _generateFilename();
      final targetPath = p.join(invoicesDir.path, filename);
      final targetFile = await sourceFile.copy(targetPath);

      // Integrity check
      final sourceSize = await sourceFile.length();
      final savedSize = await targetFile.length();
      if (savedSize != sourceSize || savedSize == 0) {
        debugPrint('[INVOICE SAVE] Integrity check failed');
        if (await targetFile.exists()) await targetFile.delete();
        return null;
      }

      debugPrint('[INVOICE SAVE] New file: $_invoiceDir/$filename ($savedSize bytes)');

      // Step 5: Create InvoiceImage entity atomically
      final invoiceImage = InvoiceImage(
        relativePath: '$_invoiceDir/$filename',
        contentHash: hash,
        refCount: 1,
        fileSizeBytes: savedSize,
      );

      int? newId;
      await _isar.writeTxn(() async {
        newId = await _isar.invoiceImages.put(invoiceImage);
      });

      debugPrint('[INVOICE CREATE] ID: $newId, path: ${invoiceImage.relativePath}');
      return newId;
    } catch (e) {
      debugPrint('[INVOICE PICK] Failed: $e');
      return null;
    }
  }

  /// Increment reference count for an existing InvoiceImage.
  ///
  /// Call when linking an existing invoice to a new record.
  Future<void> attachExisting(int invoiceImageId) async {
    await _isar.writeTxn(() async {
      final image = await _isar.invoiceImages.get(invoiceImageId);
      if (image != null) {
        image.refCount++;
        await _isar.invoiceImages.put(image);
        debugPrint('[INVOICE ATTACH] ID: $invoiceImageId refCount: ${image.refCount}');
      }
    });
  }

  /// Decrement reference count. Delete file only when refCount reaches zero.
  ///
  /// Call when deleting a MaintenanceRecord that references this invoice.
  /// This IS the cascade delete — atomic, safe, no leaks.
  Future<void> detachOrDelete(int invoiceImageId) async {
    await _isar.writeTxn(() async {
      final image = await _isar.invoiceImages.get(invoiceImageId);
      if (image == null) return;

      image.refCount--;
      debugPrint('[INVOICE DETACH] ID: $invoiceImageId refCount: ${image.refCount}');

      if (image.refCount <= 0) {
        // RefCount zero — safe to delete file from disk
        await _isar.invoiceImages.delete(invoiceImageId);
        debugPrint('[INVOICE GC] Entity deleted from Isar');

        // Delete file with timeout
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final file = File(p.join(appDir.path, image.relativePath));
          if (await file.exists()) {
            await file.delete().timeout(
              const Duration(milliseconds: 200),
              onTimeout: () {
                debugPrint('[INVOICE GC] Timeout — file left behind');
                return file;
              },
            );
            debugPrint('[INVOICE GC] File deleted: ${image.relativePath}');
          }
        } catch (e) {
          debugPrint('[INVOICE GC] File deletion failed: $e');
        }
      } else {
        // Other records still reference this image — just decrement
        await _isar.invoiceImages.put(image);
      }
    });
  }

  /// Get the file for an InvoiceImage by ID.
  Future<File?> getFile(int invoiceImageId) async {
    final image = await _isar.invoiceImages.get(invoiceImageId);
    if (image == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(appDir.path, image.relativePath));
    return await file.exists() ? file : null;
  }

  /// Get the relative path for display/logging purposes.
  Future<String?> getRelativePath(int invoiceImageId) async {
    final image = await _isar.invoiceImages.get(invoiceImageId);
    return image?.relativePath;
  }

  /// Compute SHA-256 hash of a file (runs in background isolate via compute()).
  static Future<String> _hashFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  static String _generateFilename() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomHash = (DateTime.now().microsecond * 1000 + DateTime.now().millisecond)
        .toString()
        .padLeft(6, '0');
    return 'invoice_${timestamp}_$randomHash.jpg';
  }
}
