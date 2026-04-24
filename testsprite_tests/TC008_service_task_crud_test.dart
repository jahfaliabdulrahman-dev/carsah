// TC008: Service task CRUD operations — IN-MEMORY ISAR
// Upgraded: Round 3 — real Isar CRUD operations
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

  group('TC008: Service Task CRUD (In-Memory Isar)', () {
    test('CREATE: task persists with all fields', () async {
      final task = createTestTask(
        taskKey: 'tire_rotation',
        nameEn: 'Tire Rotation',
        nameAr: 'تبديل الإطارات',
        intervalKm: 10000,
        intervalMonths: 12,
      );

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      final stored = await isar.serviceTasks.get(task.id);
      expect(stored, isNotNull);
      expect(stored!.taskKey, equals('tire_rotation'));
      expect(stored.intervalKm, equals(10000));
      expect(stored.intervalMonths, equals(12));
    });

    test('READ: query by taskKey returns correct task', () async {
      await isar.writeTxn(() async {
        await isar.serviceTasks.put(createTestTask(
          taskKey: 'oil_change_5w30',
          nameEn: 'Oil Change',
        ));
      });

      final found = await isar.serviceTasks
          .where()
          .taskKeyEqualTo('oil_change_5w30')
          .findFirst();

      expect(found, isNotNull);
      expect(found!.taskKey, contains('oil_change'));
    });

    test('UPDATE: modify task fields persists', () async {
      final task = createTestTask(
        intervalKm: 5000,
        intervalMonths: 6,
      );

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      // Update
      task.intervalKm = 7500;
      task.intervalMonths = 8;
      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      final stored = await isar.serviceTasks.get(task.id);
      expect(stored, isNotNull);
      expect(stored!.intervalKm, equals(7500));
      expect(stored.intervalMonths, equals(8));
    });

    test('DELETE: task removed from Isar', () async {
      final task = createTestTask(taskKey: 'to_delete');

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });
      expect(await isar.serviceTasks.count(), equals(1));

      await isar.writeTxn(() async {
        await isar.serviceTasks.delete(task.id);
      });
      expect(await isar.serviceTasks.count(), equals(0));
    });

    test('DELETE: removing task does not affect other tasks', () async {
      final task1 = createTestTask(taskKey: 'keep_this');
      final task2 = createTestTask(taskKey: 'delete_this');

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task1);
        await isar.serviceTasks.put(task2);
      });

      await isar.writeTxn(() async {
        await isar.serviceTasks.delete(task2.id);
      });

      expect(await isar.serviceTasks.count(), equals(1));
      final remaining = await isar.serviceTasks.where().findFirst();
      expect(remaining!.taskKey, equals('keep_this'));
    });

    test('CRUD: full lifecycle — create, read, update, delete', () async {
      // CREATE
      final task = createTestTask(
        taskKey: 'lifecycle_test',
        nameEn: 'Lifecycle Test',
        intervalKm: 5000,
      );
      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      // READ
      var stored = await isar.serviceTasks
          .where()
          .taskKeyEqualTo('lifecycle_test')
          .findFirst();
      expect(stored, isNotNull);
      expect(stored!.intervalKm, equals(5000));

      // UPDATE — use the original task object (it has the ID)
      task.intervalKm = 10000;
      task.displayNameEn = 'Updated Lifecycle Test';
      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      stored = await isar.serviceTasks.get(task.id);
      expect(stored, isNotNull);
      expect(stored!.intervalKm, equals(10000));
      expect(stored.displayNameEn, equals('Updated Lifecycle Test'));

      // DELETE
      await isar.writeTxn(() async {
        await isar.serviceTasks.delete(task.id);
      });
      expect(await isar.serviceTasks.count(), equals(0));
    });

    test('vehicleId links task to correct vehicle', () async {
      final task = createTestTask(vehicleId: 42, taskKey: 'brake_inspection');

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      final stored = await isar.serviceTasks.get(task.id);
      expect(stored!.vehicleId, equals(42));

      // Query by vehicleId
      final vehicle42Tasks = await isar.serviceTasks
          .where()
          .vehicleIdEqualTo(42)
          .findAll();
      expect(vehicle42Tasks.length, equals(1));
    });
  });
}
