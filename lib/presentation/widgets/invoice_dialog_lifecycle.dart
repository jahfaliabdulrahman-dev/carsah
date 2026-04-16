import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';

import '../../data/services/ref_counted_invoice_service.dart';

/// Cancel-Orphan Protocol — Dialog Lifecycle for Normalized Invoice Architecture
///
/// Uses int? transientImageId (InvoiceImage PK) instead of string paths.
/// RefCountedInvoiceService handles deduplication, ref counting, and file I/O.
mixin InvoiceDialogLifecycle<T extends StatefulWidget> on State<T> {
  late RefCountedInvoiceService _invoiceService;

  /// Tracks the current InvoiceImage ID in dialog state.
  int? transientImageId;

  /// The ID that existed BEFORE this dialog session.
  int? _originalImageId;
  bool _didSave = false;

  /// Call in initState with the Isar instance and existing record's invoiceImageId.
  void initInvoiceLifecycle({required Isar isar, int? initialImageId}) {
    _invoiceService = RefCountedInvoiceService(isar);
    _originalImageId = initialImageId;
    transientImageId = initialImageId;
    _didSave = false;
  }

  /// Callback when a new image is picked.
  /// Calls pickAndAttach which handles dedup and ref counting.
  Future<void> pickInvoice() async {
    final newId = await _invoiceService.pickAndAttach(
      source: ImageSource.gallery,
    );

    if (newId != null) {
      debugPrint('[DEDUP] pickAndAttach returned ID: $newId');

      // Detach old reference if replacing
      if (transientImageId != null && transientImageId != _originalImageId) {
        debugPrint('[REF_COUNT CHANGE] Detaching old transient: $transientImageId');
        await _invoiceService.detachOrDelete(transientImageId!);
      }

      setState(() {
        transientImageId = newId;
      });
      debugPrint('[REF_COUNT CHANGE] transientImageId set to: $newId');
    }
  }

  /// Call in dispose() — handles orphan cleanup ONLY if save was not confirmed.
  Future<void> disposeInvoiceLifecycle() async {
    if (_didSave) {
      debugPrint('[LIFECYCLE] dispose: save confirmed, skipping cleanup');
      return;
    }

    if (transientImageId != null && transientImageId != _originalImageId) {
      debugPrint('[LIFECYCLE] dispose: orphan cleanup for ID $transientImageId');
      await _invoiceService.detachOrDelete(transientImageId!);
    }
  }

  /// Mark save as confirmed.
  String? finalizeInvoicePath() {
    // Kept for backward compat — returns null, ID is used instead
    _didSave = true;
    debugPrint('[LIFECYCLE] finalize: _didSave=true, transientImageId=$transientImageId');
    return null;
  }

  /// Mark save as confirmed (new ID-based method).
  int? finalizeInvoiceId() {
    _didSave = true;
    debugPrint('[LIFECYCLE] finalize: _didSave=true, returning ID=$transientImageId');
    return transientImageId;
  }

  /// Revert save confirmation if Isar write fails.
  void revertSaveConfirmation() {
    debugPrint('[LIFECYCLE] reverting _didSave to false');
    _didSave = false;
  }

  /// Cleanup old image AFTER successful Isar save.
  Future<void> cleanupOldImage() async {
    if (_originalImageId != null && _originalImageId != transientImageId) {
      debugPrint('[REF_COUNT CHANGE] cleanupOldImage: detaching $_originalImageId');
      await _invoiceService.detachOrDelete(_originalImageId!);
    }
  }

  /// Get the File for the current transient image.
  Future<File?> resolveCurrentInvoiceFile() async {
    if (transientImageId == null) return null;
    return _invoiceService.getFile(transientImageId!);
  }

  /// Widget to embed in dialog body.
  Widget buildInvoicePicker() {
    return InvoicePickerWidget(
      imageId: transientImageId,
      onPickPressed: pickInvoice,
      onRemovePressed: () async {
        if (transientImageId != null && transientImageId != _originalImageId) {
          await _invoiceService.detachOrDelete(transientImageId!);
        }
        setState(() {
          transientImageId = null;
        });
      },
    );
  }
}

/// Standalone invoice picker widget for embedding in dialogs.
class InvoicePickerWidget extends StatelessWidget {
  final int? imageId;
  final VoidCallback onPickPressed;
  final VoidCallback onRemovePressed;

  const InvoicePickerWidget({
    super.key,
    required this.imageId,
    required this.onPickPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoice Photo',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (imageId == null)
          _buildEmptyState(theme)
        else
          _buildFilledState(context, theme),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickPressed,
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilledState(BuildContext context, ThemeData theme) {
    return SizedBox(
      height: 80,
      width: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Thumbnail placeholder — actual image loaded via FutureBuilder in detail
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          // Remove button
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemovePressed,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 14, color: theme.colorScheme.onError),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
