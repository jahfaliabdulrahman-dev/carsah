/// OEM maintenance interval defaults for Tank 300 (2.0L Turbo).
/// Source of truth: assets/oem/tank_300_intervals.json (GitHub Gist CDN).
/// These constants are fallbacks when CDN is offline.

abstract final class OilChange {
  static const maintenanceIntervalKm = 7500;
  static const maintenanceIntervalMonths = 6;
  static const displayNameEn = 'Oil Change';
  static const displayNameAr = 'تغيير الزيت';
}

abstract final class OilFilter {
  static const maintenanceIntervalKm = 7500;
  static const maintenanceIntervalMonths = 6;
  static const displayNameEn = 'Oil Filter';
  static const displayNameAr = 'فلتر الزيت';
}

abstract final class EngineAirFilter {
  static const maintenanceIntervalKm = 20000;
  static const maintenanceIntervalMonths = 12;
  static const displayNameEn = 'Engine Air Filter';
  static const displayNameAr = 'فلتر هواء المحرك';
}

abstract final class CabinAirFilter {
  static const maintenanceIntervalKm = 20000;
  static const maintenanceIntervalMonths = 12;
  static const displayNameEn = 'Cabin Air Filter';
  static const displayNameAr = 'فلتر هواء المقصورة';
}

abstract final class BrakeFluid {
  static const maintenanceIntervalKm = 100000;
  static const maintenanceIntervalMonths = 24;
  static const displayNameEn = 'Brake Fluid';
  static const displayNameAr = 'سائل الفرامل';
}

abstract final class Coolant {
  static const maintenanceIntervalKm = 100000;
  static const maintenanceIntervalMonths = 24;
  static const displayNameEn = 'Coolant';
  static const displayNameAr = 'سائل التبريد';
}

abstract final class SparkPlugs {
  static const maintenanceIntervalKm = 20000;
  static const maintenanceIntervalMonths = 24;
  static const displayNameEn = 'Spark Plugs';
  static const displayNameAr = 'البواجي';
}

abstract final class TransmissionFluid {
  static const maintenanceIntervalKm = 60000;
  static const maintenanceIntervalMonths = 36;
  static const displayNameEn = 'Transmission Fluid';
  static const displayNameAr = 'زيت القير';
}

abstract final class BrakePadsFront {
  static const maintenanceIntervalKm = 60000;
  static const maintenanceIntervalMonths = 24;
  static const displayNameEn = 'Front Brake Pads';
  static const displayNameAr = 'فحمات فرامل أمامي';
}

abstract final class BrakePadsRear {
  static const maintenanceIntervalKm = 60000;
  static const maintenanceIntervalMonths = 24;
  static const displayNameEn = 'Rear Brake Pads';
  static const displayNameAr = 'فحمات فرامل خلفي';
}

abstract final class TireRotation {
  static const maintenanceIntervalKm = 40000;
  static const maintenanceIntervalMonths = 12;
  static const displayNameEn = 'Tire Rotation';
  static const displayNameAr = 'تبديل الإطارات';
}

abstract final class FuelFilter {
  static const maintenanceIntervalKm = 20000;
  static const maintenanceIntervalMonths = 12;
  static const displayNameEn = 'Fuel Filter';
  static const displayNameAr = 'فلتر الوقود';
}

abstract final class TransferCaseOil {
  static const maintenanceIntervalKm = 60000;
  static const maintenanceIntervalMonths = 36;
  static const displayNameEn = 'Transfer Case Oil';
  static const displayNameAr = 'زيت الدبل';
}

abstract final class DiffFluidFront {
  static const maintenanceIntervalKm = 60000;
  static const maintenanceIntervalMonths = 36;
  static const displayNameEn = 'Front Differential Fluid';
  static const displayNameAr = 'زيت الدفرنس الأمامي';
}

abstract final class DiffFluidRear {
  static const maintenanceIntervalKm = 60000;
  static const maintenanceIntervalMonths = 36;
  static const displayNameEn = 'Rear Differential Fluid';
  static const displayNameAr = 'زيت الدفرنس الخلفي';
}

abstract final class WheelAlignment {
  static const maintenanceIntervalKm = 20000;
  static const maintenanceIntervalMonths = 12;
  static const displayNameEn = 'Wheel Alignment';
  static const displayNameAr = 'ميزان الأذرع';
}
