// TC003: Maintenance task scheduling — IN-MEMORY ISAR
// Upgraded: Round 3 — real Isar database operations
// Category: Maintenance | Priority: High

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

  group('TC003: Maintenance Scheduling (In-Memory Isar)', () {
    test('service task persists with mileage and time intervals', () async {
      final task = createTestTask(
        taskKey: 'oil_change',
        nameEn: 'Oil Change',
        nameAr: 'تغيير الزيت',
        intervalKm: 5000,
        intervalMonths: 6,
      );

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      final stored = await isar.serviceTasks.get(task.id);
      expect(stored, isNotNull);
      expect(stored!.taskKey, equals('oil_change'));
      expect(stored.displayNameEn, equals('Oil Change'));
      expect(stored.displayNameAr, equals('تغيير الزيت'));
      expect(stored.intervalKm, equals(5000));
      expect(stored.intervalMonths, equals(6));
    });

    test('service task supports bilingual names', () async {
      final task = createTestTask(
        taskKey: 'tire_rotation',
        nameEn: 'Tire Rotation',
        nameAr: 'تبديل الإطارات',
        intervalKm: 10000,
      );

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      final stored = await isar.serviceTasks.get(task.id);
      expect(stored!.displayNameAr, isNotEmpty);
      expect(stored.displayNameEn, isNotEmpty);
    });

    test('interval can be null for flexible scheduling', () async {
      final task = createTestTask(
        taskKey: 'custom_task',
        nameEn: 'Custom Task',
        nameAr: 'مهمة مخصصة',
        intervalKm: null,
        intervalMonths: null,
      );

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      final stored = await isar.serviceTasks.get(task.id);
      expect(stored!.intervalKm, isNull);
      expect(stored.intervalMonths, isNull);
    });

    test('query tasks by vehicleId returns correct subset', () async {
      // Create tasks for two vehicles
      await isar.writeTxn(() async {
        await isar.serviceTasks.put(createTestTask(
          vehicleId: 1,
          taskKey: 'oil_v1',
        ));
        await isar.serviceTasks.put(createTestTask(
          vehicleId: 1,
          taskKey: 'filter_v1',
        ));
        await isar.serviceTasks.put(createTestTask(
          vehicleId: 2,
          taskKey: 'oil_v2',
        ));
      });

      final vehicle1Tasks = await isar.serviceTasks
          .where()
          .vehicleIdEqualTo(1)
          .findAll();
      final vehicle2Tasks = await isar.serviceTasks
          .where()
          .vehicleIdEqualTo(2)
          .findAll();

      expect(vehicle1Tasks.length, equals(2));
      expect(vehicle2Tasks.length, equals(1));
      expect(vehicle1Tasks.every((t) => t.vehicleId == 1), isTrue);
    });

    test('query task by taskKey returns correct task', () async {
      await isar.writeTxn(() async {
        await isar.serviceTasks.put(createTestTask(
          taskKey: 'brake_pads_front',
          nameEn: 'Front Brake Pads',
        ));
        await isar.serviceTasks.put(createTestTask(
          taskKey: 'oil_change',
          nameEn: 'Oil Change',
        ));
      });

      final found = await isar.serviceTasks
          .where()
          .taskKeyEqualTo('oil_change')
          .findFirst();

      expect(found, isNotNull);
      expect(found!.displayNameEn, equals('Oil Change'));
    });

    test('task lastDone tracking persists correctly', () async {
      final task = createTestTask(taskKey: 'oil_change');
      final doneDate = DateTime(2026, 3, 15);

      // Set last done
      task.lastDoneKm = 20000;
      task.lastDoneDate = doneDate;

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      final stored = await isar.serviceTasks.get(task.id);
      expect(stored!.lastDoneKm, equals(20000));
      expect(stored.lastDoneDate, equals(doneDate));
    });
  });
}
