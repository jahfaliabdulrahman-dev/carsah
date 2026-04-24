# Invoice Archive — Implementation Plan

## Context

First user feedback from CarSah's WhatsApp group launch confirmed a critical feature gap:
> "If you add an invoice upload section after maintenance that gets saved like an archive, it will make reviewing maintenance and parts much easier."

This is not a "nice to have" — it's the bridge between task tracking and **vehicle financial record system**. It enables:
1. Personal archive ("What did I spend last year?")
2. Resale value proof (maintenance history for buyers)
3. Warranty claims (show dealership proof of service)

---

## Architecture Overview

```
User takes photo → image_picker → Copy to app sandbox → Store path in Isar
                                                            ↓
                              Record Detail Page ← reads invoiceImagePath ← Isar
                              Full-screen viewer ← loads from app directory
```

---

## Step 1: Add `image_picker` Dependency

**File:** `pubspec.yaml`

```yaml
dependencies:
  # ... existing ...
  image_picker: ^1.0.7
```

Note: `path_provider` is already present.

**Command:** `cd ~/maintlogic && flutter pub get`

---

## Step 2: Data Model Update

**File:** `lib/data/models/maintenance_record.dart`

Add nullable field (backward-compatible with existing data):

```dart
@collection
class MaintenanceRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late int vehicleId;

  late String serviceType;
  String? notes;
  late int odometerKm;
  late double totalCostSar;

  double partsCostSar;
  double laborCostSar;
  List<String>? partsReplaced;
  List<String>? taskKeys;
  String? providerName;
  String? invoiceImagePath;  // ← NEW: absolute path to sandboxed invoice image

  late DateTime serviceDate;
  late DateTime createdAt;

  bool isSynced;

  MaintenanceRecord({
    this.id = Isar.autoIncrement,
    required this.vehicleId,
    required this.serviceType,
    this.notes,
    required this.odometerKm,
    required this.totalCostSar,
    this.partsCostSar = 0.0,
    this.laborCostSar = 0.0,
    this.partsReplaced,
    this.taskKeys,
    this.providerName,
    this.invoiceImagePath,  // ← NEW
    required this.serviceDate,
    required this.createdAt,
    this.isSynced = false,
  });
}
```

**Regenerate schema:**
```bash
cd ~/maintlogic && dart run build_runner build --delete-conflicting-outputs
```

**Migration safety:**
- `String?` is nullable → old records without this field get `null` automatically
- No data migration needed — Isar handles this gracefully
- Schema version bumps automatically via build_runner

---

## Step 3: Invoice Image Storage Service

**New file:** `lib/core/services/invoice_storage_service.dart`

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Handles invoice image picking, copying to app sandbox, and deletion.
///
/// DESIGN RULE: Images are COPIED from gallery/camera into the app's
/// private documents directory. This ensures they survive even if the
/// user deletes the original from their photo gallery.
class InvoiceStorageService {
  final ImagePicker _picker = ImagePicker();

  /// Returns the app's private invoice directory.
  Future<Directory> get _invoiceDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/invoices');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Picks an image from gallery or camera, copies it to app sandbox,
  /// and returns the absolute path.
  ///
  /// Returns null if the user cancels.
  Future<String?> pickAndStoreInvoice({
    required ImageSource source,
  }) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final dir = await _invoiceDir;
    final fileName = 'invoice_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${dir.path}/$fileName';

    await File(picked.path).copy(savedPath);
    return savedPath;
  }

  /// Deletes an invoice image from the app sandbox.
  /// Safe to call with null — no-op.
  Future<void> deleteInvoice(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
```

**Provider:** Add to providers or use directly — this is stateless utility, no Riverpod needed.

---

## Step 4: UI — Add Record Dialog (Attachment Button)

**File:** `lib/presentation/pages/history/widgets/add_record_dialog.dart`

Add invoice attachment to the batch record dialog. Since the dialog is batch (multiple tasks at once), the invoice applies to **all records in the batch** (one receipt per service visit).

**Add state variable:**
```dart
String? _invoiceImagePath;
```

**Add UI (after Notes field, before Task Checklist):**
```dart
// — Invoice Attachment —
const SizedBox(height: 10),
InkWell(
  borderRadius: BorderRadius.circular(4),
  onTap: () => _pickInvoice(context),
  child: InputDecorator(
    decoration: InputDecoration(
      labelText: t('attach_invoice'),
      border: const OutlineInputBorder(),
      isDense: true,
      prefixIcon: Icon(
        _invoiceImagePath != null
            ? Icons.check_circle
            : Icons.receipt_long_outlined,
        size: 18,
        color: _invoiceImagePath != null
            ? Colors.green
            : null,
      ),
      suffixIcon: _invoiceImagePath != null
          ? IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => setState(() => _invoiceImagePath = null),
            )
          : const Icon(Icons.add_photo_alternate_outlined, size: 18),
    ),
    child: _invoiceImagePath != null
        ? Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  File(_invoiceImagePath!),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t('invoice_attached'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          )
        : Text(
            t('tap_to_attach'),
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
  ),
),
```

**Add picker method:**
```dart
Future<void> _pickInvoice(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: Text(t('camera')),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(t('gallery')),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );

  if (source == null) return;

  final service = InvoiceStorageService();
  final path = await service.pickAndStoreInvoice(source: source);
  if (path != null && mounted) {
    setState(() => _invoiceImagePath = path);
  }
}
```

**Update `_performSave` to pass invoiceImagePath to each record:**
```dart
final record = MaintenanceRecord(
  vehicleId: vehicleId,
  serviceType: taskMap[taskKey] ?? taskKey,
  notes: sharedNotes,
  odometerKm: odometer,
  totalCostSar: partsCost + laborPerTask,
  partsCostSar: partsCost,
  laborCostSar: laborPerTask,
  partsReplaced: [taskMap[taskKey] ?? taskKey],
  taskKeys: [taskKey],
  invoiceImagePath: _invoiceImagePath,  // ← NEW: shared across batch
  serviceDate: _selectedDate,
  createdAt: _selectedDate,
);
```

**Add import:**
```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/invoice_storage_service.dart';
```

---

## Step 5: UI — Record Detail Page (Invoice Viewer)

**File:** `lib/presentation/pages/history/record_detail_page.dart`

Add invoice card between "Notes" and the end of the column:

```dart
// — Invoice Archive —
if (record.invoiceImagePath != null)
  Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => _openFullInvoice(context, record.invoiceImagePath!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  t('invoice'),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Icon(Icons.fullscreen, size: 20,
                    color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
          Image.file(
            File(record.invoiceImagePath!),
            height: 200,
            fit: BoxFit.cover,
          ),
        ],
      ),
    ),
  ),
```

**Add full-screen viewer method:**
```dart
void _openFullInvoice(BuildContext context, String imagePath) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => _InvoiceViewerPage(imagePath: imagePath),
    ),
  );
}
```

**New widget at bottom of file:**
```dart
/// Full-screen invoice viewer with pinch-to-zoom.
class _InvoiceViewerPage extends StatelessWidget {
  final String imagePath;

  const _InvoiceViewerPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice'), // No translation needed — proper noun
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
```

**Add import:**
```dart
import 'dart:io';
```

---

## Step 6: UI — Edit Record Dialog (Preserve Field)

**File:** `lib/presentation/pages/history/widgets/edit_record_dialog.dart`

Update the `_onSave()` method's `MaintenanceRecord` constructor to preserve the invoice path:

```dart
final updated = MaintenanceRecord(
  id: widget.record.id,
  vehicleId: widget.record.vehicleId,
  serviceType: widget.record.serviceType,
  notes: newNotes,
  odometerKm: newOdometer,
  totalCostSar: newPartsCost + newLaborCost,
  partsCostSar: newPartsCost,
  laborCostSar: newLaborCost,
  partsReplaced: widget.record.partsReplaced,
  taskKeys: widget.record.taskKeys,
  providerName: widget.record.providerName,
  invoiceImagePath: widget.record.invoiceImagePath,  // ← NEW: preserve
  serviceDate: _selectedDate,
  createdAt: widget.record.createdAt,
  isSynced: widget.record.isSynced,
);
```

---

## Step 7: Delete Behavior (Cleanup)

**File:** `lib/data/repositories/maintenance_repository_impl.dart`

Update `deleteRecord` to clean up the invoice image when a record is deleted:

```dart
@override
Future<bool> deleteRecord(int recordId) async {
  try {
    final existing = await isar.maintenanceRecords.get(recordId);
    if (existing == null) return false;

    // Clean up invoice image if exists.
    if (existing.invoiceImagePath != null) {
      final file = File(existing.invoiceImagePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    // ... rest of existing rollback logic unchanged ...
```

**Add import:**
```dart
import 'dart:io';
```

---

## Step 8: Translation Keys

**File:** `lib/presentation/providers/settings_provider.dart`

Add to `_translations` map:

```dart
// Invoice Archive
'attach_invoice': {'en': 'Attach Invoice', 'ar': 'إرفاق فاتورة'},
'tap_to_attach': {'en': 'Tap to attach invoice photo', 'ar': 'اضغط لإرفاق صورة الفاتورة'},
'invoice_attached': {'en': 'Invoice attached', 'ar': 'تم إرفاق الفاتورة'},
'invoice': {'en': 'Invoice', 'ar': 'الفاتورة'},
'camera': {'en': 'Camera', 'ar': 'الكاميرا'},
'gallery': {'en': 'Gallery', 'ar': 'الاستوديو'},
```

---

## Step 9: Setup Wizard (Preserve Field)

**File:** `lib/presentation/pages/setup/setup_wizard_page.dart`

Check if the wizard creates `MaintenanceRecord` instances. If so, add `invoiceImagePath: null` explicitly (optional — nullable defaults to null).

---

## Files Modified Summary

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `image_picker: ^1.0.7` |
| `lib/data/models/maintenance_record.dart` | Add `String? invoiceImagePath` field + constructor param |
| `lib/data/models/maintenance_record.g.dart` | Auto-regenerated via build_runner |
| `lib/core/services/invoice_storage_service.dart` | **NEW** — image pick + sandbox copy + delete |
| `lib/presentation/pages/history/widgets/add_record_dialog.dart` | Add invoice picker UI + pass to records |
| `lib/presentation/pages/history/record_detail_page.dart` | Add invoice card + full-screen viewer |
| `lib/presentation/pages/history/widgets/edit_record_dialog.dart` | Preserve `invoiceImagePath` on edit |
| `lib/data/repositories/maintenance_repository_impl.dart` | Clean up image file on record delete |
| `lib/presentation/providers/settings_provider.dart` | Add 6 translation keys |

---

## Execution Order

1. `pubspec.yaml` → `flutter pub get`
2. `maintenance_record.dart` → `build_runner build`
3. `invoice_storage_service.dart` (new file)
4. `settings_provider.dart` (translations)
5. `add_record_dialog.dart` (attach UI)
6. `record_detail_page.dart` (view UI)
7. `edit_record_dialog.dart` (preserve field)
8. `maintenance_repository_impl.dart` (delete cleanup)
9. Build & test

---

## Verification Checklist

- [ ] `build_runner` succeeds without errors
- [ ] App launches without Isar migration crash (null-safe field)
- [ ] Can attach invoice from camera in Add Record dialog
- [ ] Can attach invoice from gallery in Add Record dialog
- [ ] Thumbnail preview shows in dialog after attaching
- [ ] Invoice image appears in Record Detail page
- [ ] Tapping invoice opens full-screen zoom viewer
- [ ] Editing a record preserves the invoice path
- [ ] Deleting a record cleans up the image file
- [ ] Old records (no invoice) display normally without errors
- [ ] Arabic translations display correctly
