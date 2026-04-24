// TC002: Vehicle creation with all required fields — IN-MEMORY ISAR
// Upgraded: Round 3 — real Isar database operations
// Category: Vehicle Management | Priority: High

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

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

  group('TC002: Vehicle Creation (In-Memory Isar)', () {
    test('vehicle persists to Isar and reads back correctly', () async {
      final vehicle = createTestVehicle(
        name: 'My Tank 300',
        make: 'Tank',
        model: '300',
        year: 2024,
        odometer: 15000,
      );

      // Write
      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });

      // Read
      final stored = await isar.vehicles.get(vehicle.id);
      expect(stored, isNotNull);
      expect(stored!.name, equals('My Tank 300'));
      expect(stored.make, equals('Tank'));
      expect(stored.model, equals('300'));
      expect(stored.year, equals(2024));
      expect(stored.currentOdometerKm, equals(15000));
    });

    test('vehicle accepts zero odometer for new vehicles', () async {
      final vehicle = createTestVehicle(odometer: 0);

      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });

      final stored = await isar.vehicles.get(vehicle.id);
      expect(stored!.currentOdometerKm, equals(0));
    });

    test('vehicle has auto-increment ID assigned by Isar', () async {
      final vehicle1 = createTestVehicle(name: 'Car 1');
      final vehicle2 = createTestVehicle(name: 'Car 2');

      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle1);
        await isar.vehicles.put(vehicle2);
      });

      expect(vehicle1.id, isNot(equals(vehicle2.id)));
      expect(vehicle1.id, greaterThan(0));
      expect(vehicle2.id, greaterThan(0));
    });

    test('vehicle count is accurate after inserts', () async {
      expect(await isar.vehicles.count(), equals(0));

      await isar.writeTxn(() async {
        await isar.vehicles.put(createTestVehicle(name: 'Car 1'));
      });
      expect(await isar.vehicles.count(), equals(1));

      await isar.writeTxn(() async {
        await isar.vehicles.put(createTestVehicle(name: 'Car 2'));
      });
      expect(await isar.vehicles.count(), equals(2));
    });

    test('vehicle isActive flag defaults to false', () async {
      final vehicle = Vehicle(
        name: 'Test',
        make: 'Test',
        model: 'Test',
        year: 2024,
        currentOdometerKm: 0,
        addedAt: DateTime.now(),
      );

      expect(vehicle.isActive, isFalse);
    });

    test('vehicle update persists changes', () async {
      final vehicle = createTestVehicle(odometer: 10000);

      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });

      // Update odometer
      vehicle.currentOdometerKm = 12000;
      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });

      final stored = await isar.vehicles.get(vehicle.id);
      expect(stored!.currentOdometerKm, equals(12000));
    });
  });
}
