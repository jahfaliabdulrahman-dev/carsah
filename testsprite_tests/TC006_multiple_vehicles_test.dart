// TC006: Multiple vehicle management — IN-MEMORY ISAR
// Upgraded: Round 3 — real Isar multi-vehicle isolation
// Category: Vehicle Management | Priority: Medium

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

  group('TC006: Multiple Vehicles (In-Memory Isar)', () {
    test('each vehicle has unique identity in Isar', () async {
      final v1 = createTestVehicle(name: 'Tank 300', make: 'Tank');
      final v2 = createTestVehicle(name: 'Toyota Camry', make: 'Toyota');

      await isar.writeTxn(() async {
        await isar.vehicles.put(v1);
        await isar.vehicles.put(v2);
      });

      expect(v1.id, isNot(equals(v2.id)));
      expect(v1.name, isNot(equals(v2.name)));
      expect(v1.make, isNot(equals(v2.make)));
    });

    test('vehicle odometer updates independently in Isar', () async {
      final vehicle = createTestVehicle(odometer: 15000);

      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });

      // Update
      vehicle.currentOdometerKm = 16000;
      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });

      final stored = await isar.vehicles.get(vehicle.id);
      expect(stored!.currentOdometerKm, equals(16000));
    });

    test('vehicle data isolation: no leakage between vehicles', () async {
      // Create two vehicles with different data
      final v1 = createTestVehicle(name: 'Car A', odometer: 10000);
      final v2 = createTestVehicle(name: 'Car B', odometer: 50000);

      await isar.writeTxn(() async {
        await isar.vehicles.put(v1);
        await isar.vehicles.put(v2);
      });

      // Read each independently
      final stored1 = await isar.vehicles.get(v1.id);
      final stored2 = await isar.vehicles.get(v2.id);

      expect(stored1!.name, equals('Car A'));
      expect(stored1.currentOdometerKm, equals(10000));
      expect(stored2!.name, equals('Car B'));
      expect(stored2.currentOdometerKm, equals(50000));
    });

    test('getAll returns all vehicles', () async {
      await isar.writeTxn(() async {
        await isar.vehicles.put(createTestVehicle(name: 'Car 1'));
        await isar.vehicles.put(createTestVehicle(name: 'Car 2'));
        await isar.vehicles.put(createTestVehicle(name: 'Car 3'));
      });

      final all = await isar.vehicles.where().findAll();
      expect(all.length, equals(3));
    });

    test('isActive flag: query by filtering in memory', () async {
      final v1 = createTestVehicle(name: 'Active Car', isActive: true);
      final v2 = createTestVehicle(name: 'Inactive Car', isActive: false);

      await isar.writeTxn(() async {
        await isar.vehicles.put(v1);
        await isar.vehicles.put(v2);
      });

      final all = await isar.vehicles.where().findAll();
      final active = all.where((v) => v.isActive).toList();
      expect(active.length, equals(1));
      expect(active.first.name, equals('Active Car'));
    });

    test('delete vehicle removes from Isar', () async {
      final vehicle = createTestVehicle();

      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });
      expect(await isar.vehicles.count(), equals(1));

      await isar.writeTxn(() async {
        await isar.vehicles.delete(vehicle.id);
      });
      expect(await isar.vehicles.count(), equals(0));
    });
  });
}
