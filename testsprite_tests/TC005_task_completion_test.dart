// TC005: Task completion and history tracking — IN-MEMORY ISAR
// Upgraded: Round 3 — real Isar CRUD with task completion flow
// Category: Maintenance | Priority: High

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:maintlogic/data/models/maintenance_record.dart';
import 'package:maintlogic/data/models/service_task.dart';
import 'package:maintlogic/data/models/vehicle.dart';
import 'helpers/test_helpers.dart';

void main() {
  late Isar isar;

  setUp(() async {
    isar = await openTestIsar();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('TC005: Task Completion (In-Memory Isar)', () {
    test('maintenance record persists with all required fields', () async {
      final record = createTestRecord(
        serviceType: 'Oil Change',
        odometer: 20000,
        totalCost: 150.0,
      );

      await isar.writeTxn(() async {
        await isar.maintenanceRecords.put(record);
      });

      final stored = await isar.maintenanceRecords.get(record.id);
      expect(stored, isNotNull);
      expect(stored!.serviceType, equals('Oil Change'));
      expect(stored.totalCostSar, equals(150.0));
      expect(stored.odometerKm, equals(20000));
    });

    test('maintenance record has cost breakdown fields', () async {
      final record = createTestRecord(
        partsCost: 300.0,
        laborCost: 200.0,
        totalCost: 500.0,
      );

      await isar.writeTxn(() async {
        await isar.maintenanceRecords.put(record);
      });

      final stored = await isar.maintenanceRecords.get(record.id);
      expect(stored!.partsCostSar, equals(300.0));
      expect(stored.laborCostSar, equals(200.0));
      expect(stored.totalCostSar, equals(500.0));
    });

    test('maintenance record tracks parts replaced', () async {
      final record = createTestRecord(
        partsReplaced: ['Oil Filter', 'Engine Oil 5W-30'],
      );

      await isar.writeTxn(() async {
        await isar.maintenanceRecords.put(record);
      });

      final stored = await isar.maintenanceRecords.get(record.id);
      expect(stored!.partsReplaced, isNotNull);
      expect(stored.partsReplaced!.length, equals(2));
      expect(stored.partsReplaced, contains('Oil Filter'));
    });

    test('completing task updates lastDone on ServiceTask', () async {
      final task = createTestTask(
        taskKey: 'oil_change',
        nameEn: 'Oil Change',
        intervalKm: 7500,
      );

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      // Simulate completion
      task.lastDoneKm = 20000;
      task.lastDoneDate = DateTime(2026, 4, 16);

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      final storedTask = await isar.serviceTasks.get(task.id);
      expect(storedTask, isNotNull);
      expect(storedTask!.lastDoneKm, equals(20000));
      expect(storedTask.lastDoneDate, isNotNull);
    });

    test('full flow: task → complete → history exists', () async {
      final vehicle = createTestVehicle(odometer: 15000);
      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });

      final task = createTestTask(
        vehicleId: vehicle.id,
        taskKey: 'oil_change',
        nameEn: 'Oil Change',
        intervalKm: 7500,
      );
      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      final record = createTestRecord(
        vehicleId: vehicle.id,
        serviceType: 'Oil Change',
        odometer: 22500,
        totalCost: 180.0,
        taskKeys: ['oil_change'],
      );
      await isar.writeTxn(() async {
        await isar.maintenanceRecords.put(record);
      });

      task.lastDoneKm = 22500;
      task.lastDoneDate = DateTime.now();
      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      final history = await isar.maintenanceRecords
          .where()
          .vehicleIdEqualTo(vehicle.id)
          .findAll();
      expect(history.length, equals(1));
      expect(history.first.totalCostSar, equals(180.0));

      final updatedTask = await isar.serviceTasks.get(task.id);
      expect(updatedTask!.lastDoneKm, equals(22500));
    });

    test('query records by vehicleId returns correct subset', () async {
      await isar.writeTxn(() async {
        await isar.maintenanceRecords.put(
          createTestRecord(vehicleId: 1, serviceType: 'Oil Change'),
        );
        await isar.maintenanceRecords.put(
          createTestRecord(vehicleId: 1, serviceType: 'Tire Rotation'),
        );
        await isar.maintenanceRecords.put(
          createTestRecord(vehicleId: 2, serviceType: 'Oil Change'),
        );
      });

      final v1Records = await isar.maintenanceRecords
          .where()
          .vehicleIdEqualTo(1)
          .findAll();
      expect(v1Records.length, equals(2));
    });

    test('delete record removes from Isar', () async {
      final record = createTestRecord();

      await isar.writeTxn(() async {
        await isar.maintenanceRecords.put(record);
      });
      expect(await isar.maintenanceRecords.count(), equals(1));

      await isar.writeTxn(() async {
        await isar.maintenanceRecords.delete(record.id);
      });
      expect(await isar.maintenanceRecords.count(), equals(0));
    });
  });
}
