import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InsightsProvider extends ChangeNotifier {
  static const _mileageKey = 'mileage_enabled';
  static const _mileageMilesKey = 'mileage_estimate';
  static const _homeOfficeKey = 'home_office_sqft';

  bool _mileageEnabled = false;
  int _mileageEstimate = 0;
  int _homeOfficeSqft = 0;

  // IRS standard mileage rate 2026
  static const double mileageRate = 0.70;
  static const double homeOfficeRate = 5.0;
  static const int homeOfficeMax = 300;

  bool get mileageEnabled => _mileageEnabled;
  int get mileageEstimate => _mileageEstimate;
  double get mileageValue => _mileageEstimate * mileageRate;
  int get homeOfficeSqft => _homeOfficeSqft;
  int get homeOfficeValue => (_homeOfficeSqft * homeOfficeRate).toInt();
  int get homeOfficeMaxValue => (homeOfficeMax * homeOfficeRate).toInt();

  // Recurring expenses
  int get recurringCount {
    final box = Hive.box('settings');
    final list = box.get('recurring_expenses', defaultValue: <Map>[]);
    return (list as List).length;
  }

  double get recurringMonthly {
    final box = Hive.box('settings');
    final list = box.get('recurring_expenses', defaultValue: <Map>[]);
    double total = 0;
    for (final item in list) {
      total += (item['amount'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  // Tax deadline: April 15
  int get daysUntilTaxDeadline {
    final now = DateTime.now();
    final deadline = DateTime(now.year, 4, 15);
    if (now.isAfter(deadline)) {
      return DateTime(now.year + 1, 4, 15).difference(now).inDays;
    }
    return deadline.difference(now).inDays;
  }

  void init() {
    final box = Hive.box('settings');
    _mileageEnabled = box.get(_mileageKey, defaultValue: false);
    _mileageEstimate = box.get(_mileageMilesKey, defaultValue: 0);
    _homeOfficeSqft = box.get(_homeOfficeKey, defaultValue: 0);
  }

  void refresh() {
    init();
    notifyListeners();
  }

  void toggleMileage() {
    _mileageEnabled = !_mileageEnabled;
    if (_mileageEnabled && _mileageEstimate == 0) {
      // Estimate: 20 workdays × 15 miles round trip
      _mileageEstimate = 300;
    }
    Hive.box('settings').put(_mileageKey, _mileageEnabled);
    Hive.box('settings').put(_mileageMilesKey, _mileageEstimate);
    notifyListeners();
  }

  void setMileageEstimate(int miles) {
    _mileageEstimate = miles;
    Hive.box('settings').put(_mileageMilesKey, _mileageEstimate);
    notifyListeners();
  }

  void setHomeOfficeSqft(int sqft) {
    _homeOfficeSqft = sqft.clamp(0, homeOfficeMax);
    Hive.box('settings').put(_homeOfficeKey, _homeOfficeSqft);
    notifyListeners();
  }
}
