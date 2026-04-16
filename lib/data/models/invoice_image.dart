import 'package:isar/isar.dart';

part 'invoice_image.g.dart';

/// Normalized invoice image entity with reference counting.
///
/// Multiple MaintenanceRecords can reference the same InvoiceImage.
/// The file is only deleted from disk when refCount reaches zero.
/// Content hash enables deduplication — identical invoices are never stored twice.
@collection
class InvoiceImage {
  Id id = Isar.autoIncrement;

  /// Relative path in app sandbox (e.g., "invoices/invoice_xxx.jpg")
  late String relativePath;

  /// SHA-256 hash of file contents for deduplication
  @Index(unique: true)
  late String contentHash;

  /// Number of MaintenanceRecords referencing this image
  int refCount = 1;

  /// File size in bytes (for diagnostics)
  int fileSizeBytes = 0;

  late DateTime createdAt;

  InvoiceImage({
    required this.relativePath,
    required this.contentHash,
    this.refCount = 1,
    this.fileSizeBytes = 0,
  }) : createdAt = DateTime.now();
}
