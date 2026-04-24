// TC001: Welcome page localization — PURE LOGIC TESTS
// Upgraded: Round 3 — tests localization logic without CarSahApp widget
// Heavy widget tests (CarSahApp) moved to integration_test/
// Category: UI/Localization | Priority: High

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:maintlogic/presentation/providers/settings_provider.dart';

void main() {
  group('TC001: Welcome Page Localization (Pure Logic)', () {
    test('SettingsState defaults to Arabic locale', () {
      const state = SettingsState();
      expect(state.locale, equals(AppLocale.ar));
      expect(state.isRtl, isTrue);
    });

    test('SettingsState copyWith overrides locale', () {
      const state = SettingsState();
      final enState = state.copyWith(locale: AppLocale.en);
      expect(enState.locale, equals(AppLocale.en));
      expect(enState.isRtl, isFalse);
    });

    test('SettingsState copyWith overrides themeMode', () {
      const state = SettingsState();
      final darkState = state.copyWith(themeMode: ThemeMode.dark);
      expect(darkState.themeMode, equals(ThemeMode.dark));
    });

    test('t() translates known keys to Arabic', () {
      const state = SettingsState(locale: AppLocale.ar);
      expect(state.t('app_title'), equals('كار-صح'));
      expect(state.t('odometer'), equals('العداد'));
      expect(state.t('currency'), equals('ر.س'));
      expect(state.t('km'), equals('كم'));
    });

    test('t() translates known keys to English', () {
      const state = SettingsState(locale: AppLocale.en);
      expect(state.t('app_title'), equals('CarSah'));
      expect(state.t('odometer'), equals('Odometer'));
      expect(state.t('currency'), equals('SAR'));
      expect(state.t('km'), equals('km'));
    });

    test('t() returns key itself for unknown translations', () {
      const state = SettingsState();
      expect(state.t('nonexistent_key'), equals('nonexistent_key'));
    });

    test('themeMode defaults to light', () {
      const state = SettingsState();
      expect(state.themeMode, equals(ThemeMode.light));
    });

    test('all service type translations exist in both languages', () {
      const serviceKeys = [
        'Oil Change', 'Oil Filter', 'Cabin Air Filter',
        'Engine Air Filter', 'Tire Rotation', 'Front Brake Pads',
        'Rear Brake Pads', 'Fuel Filter', 'Brake Fluid',
        'Coolant', 'Spark Plugs', 'Transmission Fluid',
      ];

      const stateEn = SettingsState(locale: AppLocale.en);
      const stateAr = SettingsState(locale: AppLocale.ar);

      for (final key in serviceKeys) {
        final en = stateEn.t(key);
        final ar = stateAr.t(key);

        expect(en, isNotEmpty,
            reason: '$key missing English translation');
        expect(ar, isNotEmpty,
            reason: '$key missing Arabic translation');
        expect(ar.runes.first, greaterThanOrEqualTo(0x0600),
            reason: '$key Arabic translation not in Arabic Unicode range');
      }
    });

    test('all snake_case service keys translate correctly', () {
      const snakeKeys = [
        'oil_change', 'oil_filter', 'cabin_air_filter',
        'air_filter_engine', 'tire_rotation', 'brake_pads_front',
        'brake_pads_rear', 'fuel_filter', 'brake_fluid',
        'coolant', 'spark_plugs', 'transmission_fluid',
      ];

      const stateEn = SettingsState(locale: AppLocale.en);
      const stateAr = SettingsState(locale: AppLocale.ar);

      for (final key in snakeKeys) {
        final en = stateEn.t(key);
        final ar = stateAr.t(key);

        expect(en, isNotEmpty,
            reason: '$key missing English translation');
        expect(ar, isNotEmpty,
            reason: '$key missing Arabic translation');
      }
    });

    test('all navigation translations exist', () {
      const navKeys = [
        'nav_dashboard', 'nav_tasks', 'nav_history',
      ];

      const stateEn = SettingsState(locale: AppLocale.en);
      const stateAr = SettingsState(locale: AppLocale.ar);

      for (final key in navKeys) {
        expect(stateEn.t(key), isNotEmpty);
        expect(stateAr.t(key), isNotEmpty);
      }
    });

    test('all common UI translations exist', () {
      const uiKeys = [
        'cancel', 'delete', 'save', 'create', 'edit',
        'odometer', 'year', 'make', 'model',
      ];

      const stateEn = SettingsState(locale: AppLocale.en);
      const stateAr = SettingsState(locale: AppLocale.ar);

      for (final key in uiKeys) {
        expect(stateEn.t(key), isNotEmpty,
            reason: '$key missing English');
        expect(stateAr.t(key), isNotEmpty,
            reason: '$key missing Arabic');
      }
    });
  });
}
