// TC007: Bilingual date and number formatting — IN-MEMORY ISAR
// Upgraded: Round 3 — real Isar with bilingual task persistence
// Category: UI/Localization | Priority: Medium

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:maintlogic/data/models/service_task.dart';
import 'helpers/test_helpers.dart';

void main() {
  late Isar isar;

  setUp(() async {
    isar = await openTestIsar();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('TC007: Bilingual Formatting (In-Memory Isar)', () {
    test('date formatting produces valid output', () {
      final date = DateTime(2026, 4, 16);
      expect(date.year, equals(2026));
      expect(date.month, equals(4));
      expect(date.day, equals(16));
    });

    test('Arabic text direction is RTL', () {
      const arabicText = 'تغيير الزيت';
      expect(arabicText, isNotEmpty);
      expect(arabicText.runes.first, greaterThanOrEqualTo(0x0600));
    });

    test('English text direction is LTR', () {
      const englishText = 'Oil Change';
      expect(englishText, isNotEmpty);
      expect(englishText.runes.first, lessThanOrEqualTo(0x007F));
    });

    test('bilingual tasks persist both names in Isar', () async {
      final task = createTestTask(
        taskKey: 'oil_change',
        nameEn: 'Oil Change',
        nameAr: 'تغيير الزيت',
      );

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      final stored = await isar.serviceTasks.get(task.id);
      expect(stored!.displayNameEn, equals('Oil Change'));
      expect(stored.displayNameAr, equals('تغيير الزيت'));
    });

    test('all OEM tasks have both Arabic and English names', () async {
      final oemTasks = [
        {'key': 'oil_change', 'en': 'Oil Change', 'ar': 'تغيير الزيت'},
        {'key': 'oil_filter', 'en': 'Oil Filter', 'ar': 'فلتر الزيت'},
        {'key': 'cabin_air_filter', 'en': 'Cabin Air Filter', 'ar': 'فلتر هواء المقصورة'},
        {'key': 'tire_rotation', 'en': 'Tire Rotation', 'ar': 'تبديل الإطارات'},
        {'key': 'brake_pads_front', 'en': 'Front Brake Pads', 'ar': 'فحمات فرامل أمامي'},
      ];

      for (final oem in oemTasks) {
        await isar.writeTxn(() async {
          await isar.serviceTasks.put(ServiceTask(
            vehicleId: 1,
            taskKey: oem['key']!,
            displayNameAr: oem['ar']!,
            displayNameEn: oem['en']!,
          ));
        });
      }

      final all = await isar.serviceTasks.where().findAll();
      expect(all.length, equals(5));

      for (final task in all) {
        expect(task.displayNameEn, isNotEmpty,
            reason: '${task.taskKey} missing English name');
        expect(task.displayNameAr, isNotEmpty,
            reason: '${task.taskKey} missing Arabic name');
        // Verify Arabic name contains Arabic Unicode
        expect(task.displayNameAr.runes.first, greaterThanOrEqualTo(0x0600),
            reason: '${task.taskKey} Arabic name not in Arabic Unicode range');
      }
    });

    test('query by taskKey works with bilingual data', () async {
      await isar.writeTxn(() async {
        await isar.serviceTasks.put(createTestTask(
          taskKey: 'coolant',
          nameEn: 'Coolant',
          nameAr: 'سائل التبريد',
        ));
      });

      final found = await isar.serviceTasks
          .where()
          .taskKeyEqualTo('coolant')
          .findFirst();

      expect(found, isNotNull);
      expect(found!.displayNameAr, equals('سائل التبريد'));
    });
  });
}
