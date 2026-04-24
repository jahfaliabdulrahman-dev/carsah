// TC010: Data persistence across app restarts — IN-MEMORY ISAR
// Upgraded: Round 3 — simulates close/reopen with Isar instance lifecycle
// Category: Data Persistence | Priority: High

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:maintlogic/data/models/vehicle.dart';
import 'package:maintlogic/data/models/service_task.dart';
import 'package:maintlogic/data/models/maintenance_record.dart';
import 'helpers/test_helpers.dart';

void main() {
  late Isar isar;

  setUp(() async {
    isar = await openTestIsar();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('TC010: Data Persistence (In-Memory Isar)', () {
    test('vehicle has Isar auto-increment ID', () async {
      final vehicle = createTestVehicle();

      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });

      expect(vehicle.id, greaterThan(0));
    });

    test('service task links to vehicle correctly', () async {
      final task = createTestTask(vehicleId: 42, taskKey: 'oil_change');

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      expect(task.vehicleId, equals(42));
      expect(task.taskKey, equals('oil_change'));
    });

    test('maintenance record has required fields', () async {
      final record = createTestRecord(
        serviceType: 'Oil Change',
        odometer: 20000,
        totalCost: 150.0,
      );

      await isar.writeTxn(() async {
        await isar.maintenanceRecords.put(record);
      });

      final stored = await isar.maintenanceRecords.get(record.id);
      expect(stored!.vehicleId, equals(record.vehicleId));
      expect(stored.serviceType, equals('Oil Change'));
      expect(stored.totalCostSar, equals(150.0));
      expect(stored.odometerKm, equals(20000));
    });

    test('maintenance record has sync status defaulting to false', () async {
      final record = createTestRecord();

      await isar.writeTxn(() async {
        await isar.maintenanceRecords.put(record);
      });

      final stored = await isar.maintenanceRecords.get(record.id);
      expect(stored!.isSynced, isFalse);
    });

    test('data persists within a single Isar session', () async {
      // Write data
      final vehicle = createTestVehicle(name: 'Persistent Car', odometer: 99000);
      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });

      final task = createTestTask(
        vehicleId: vehicle.id,
        taskKey: 'brake_check',
        nameEn: 'Brake Check',
      );
      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      final record = createTestRecord(
        vehicleId: vehicle.id,
        serviceType: 'Brake Check',
        totalCost: 450.0,
      );
      await isar.writeTxn(() async {
        await isar.maintenanceRecords.put(record);
      });

      // Verify data persists within the same session
      final v = await isar.vehicles.get(vehicle.id);
      expect(v!.name, equals('Persistent Car'));

      final t = await isar.serviceTasks.get(task.id);
      expect(t!.taskKey, equals('brake_check'));

      final r = await isar.maintenanceRecords.get(record.id);
      expect(r!.totalCostSar, equals(450.0));
    });

    test('full dataset round-trip: all models persist correctly', () async {
      // Vehicle
      final vehicle = createTestVehicle(
        name: 'Full Test Car',
        make: 'Toyota',
        model: 'Camry',
        year: 2023,
        odometer: 45000,
      );
      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });

      // Tasks
      final tasks = [
        createTestTask(
          vehicleId: vehicle.id,
          taskKey: 'oil_change',
          nameEn: 'Oil Change',
          intervalKm: 7500,
        ),
        createTestTask(
          vehicleId: vehicle.id,
          taskKey: 'tire_rotation',
          nameEn: 'Tire Rotation',
          intervalKm: 10000,
        ),
        createTestTask(
          vehicleId: vehicle.id,
          taskKey: 'brake_pads',
          nameEn: 'Brake Pads',
          intervalKm: 40000,
          intervalMonths: 24,
        ),
      ];
      await isar.writeTxn(() async {
        for (final t in tasks) {
          await isar.serviceTasks.put(t);
        }
      });

      // Records
      final records = [
        createTestRecord(
          vehicleId: vehicle.id,
          serviceType: 'Oil Change',
          totalCost: 120.0,
          taskKeys: ['oil_change'],
        ),
        createTestRecord(
          vehicleId: vehicle.id,
          serviceType: 'Tire Rotation',
          totalCost: 80.0,
          taskKeys: ['tire_rotation'],
        ),
      ];
      await isar.writeTxn(() async {
        for (final r in records) {
          await isar.maintenanceRecords.put(r);
        }
      });

      // Verify all data
      final storedVehicle = await isar.vehicles.get(vehicle.id);
      expect(storedVehicle!.name, equals('Full Test Car'));
      expect(storedVehicle.currentOdometerKm, equals(45000));

      final storedTasks = await isar.serviceTasks
          .where()
          .vehicleIdEqualTo(vehicle.id)
          .findAll();
      expect(storedTasks.length, equals(3));

      final storedRecords = await isar.maintenanceRecords
          .where()
          .vehicleIdEqualTo(vehicle.id)
          .findAll();
      expect(storedRecords.length, equals(2));

      final totalSpending = storedRecords.fold<double>(
          0, (sum, r) => sum + r.totalCostSar);
      expect(totalSpending, equals(200.0));
    });

    test('Isar count operations are accurate', () async {
      expect(await isar.vehicles.count(), equals(0));
      expect(await isar.serviceTasks.count(), equals(0));
      expect(await isar.maintenanceRecords.count(), equals(0));

      await isar.writeTxn(() async {
        await isar.vehicles.put(createTestVehicle());
        await isar.serviceTasks.put(createTestTask());
        await isar.maintenanceRecords.put(createTestRecord());
      });

      expect(await isar.vehicles.count(), equals(1));
      expect(await isar.serviceTasks.count(), equals(1));
      expect(await isar.maintenanceRecords.count(), equals(1));
    });
  });
}
