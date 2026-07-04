import 'package:hive_flutter/hive_flutter.dart';

/// IRS rates and constants that change annually.
/// Stored in a versioned Hive box separate from user data.
/// When the app updates with new rates, user data (receipts, trips, settings) is never touched.
class IrsConfig {
  static const _boxName = 'irs_config';
  static const _versionKey = 'config_version';
  static const _currentVersion = 1;

  // ── 2025 values (version 1) ──
  // Increment _currentVersion when updating for 2026/2027
  static const Map<String, double> _defaults = {
    'mileage_rate': 0.70,          // IRS 2025 standard mileage rate (Pub 463)
    'home_office_rate': 5.0,       // IRS simplified method (Pub 587)
    'home_office_max_sqft': 300,   // Max 300 sq ft
    'home_office_max_deduction': 1500.0, // $5 × 300
    'se_tax_rate': 0.153,           // 12.4% SS + 2.9% Medicare
    'ss_wage_base': 184500,         // 2026 SS wage cap (Pub 15)
    'estimated_effective_rate': 0.25, // Blended income tax estimate
    'qbi_deduction_rate': 0.20,     // QBI deduction (IRC §199A)
    'sep_ira_max_rate': 0.25,       // SEP-IRA contribution limit
    'overtime_deduction_cap': 12500, // 2025-2028 overtime deduction (P.L. 119-21)
    'standard_deduction_single': 15000, // 2026 standard deduction
  };

  static Box? _box;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _box = await Hive.openBox(_boxName);
    final storedVersion = _box!.get(_versionKey, defaultValue: 0) as int;

    if (storedVersion < _currentVersion) {
      // Migration: apply new defaults without touching user data
      for (final entry in _defaults.entries) {
        await _box!.put(entry.key, entry.value);
      }
      await _box!.put(_versionKey, _currentVersion);
    } else {
      // Ensure all keys exist (first launch)
      for (final entry in _defaults.entries) {
        if (!_box!.containsKey(entry.key)) {
          await _box!.put(entry.key, entry.value);
        }
      }
    }
    _initialized = true;
  }

  // ── Getters ──

  static double get mileageRate => _box?.get('mileage_rate', defaultValue: 0.70) ?? 0.70;
  static double get homeOfficeRate => _box?.get('home_office_rate', defaultValue: 5.0) ?? 5.0;
  static int get homeOfficeMaxSqft => _box?.get('home_office_max_sqft', defaultValue: 300) ?? 300;
  static double get seTaxRate => _box?.get('se_tax_rate', defaultValue: 0.153) ?? 0.153;
  static double get estimatedEffectiveRate => _box?.get('estimated_effective_rate', defaultValue: 0.25) ?? 0.25;
  static double get qbiDeductionRate => _box?.get('qbi_deduction_rate', defaultValue: 0.20) ?? 0.20;

  /// Current config version (for display in Settings).
  static int get version => _currentVersion;

  /// Label for the IRS tax year this config covers.
  static String get taxYearLabel => '2025';
}
