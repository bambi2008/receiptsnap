import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/mileage_log.dart';

class InsightsProvider extends ChangeNotifier {
  static const _mileageKey = 'mileage_enabled';
  static const _mileageMilesKey = 'mileage_estimate';
  static const _homeOfficeKey = 'home_office_sqft';
  static const _incomeKey = 'annual_income';
  static const _remindersKey = 'quarterly_reminders_enabled';

  bool _mileageEnabled = false;
  int _mileageEstimate = 0;
  int _homeOfficeSqft = 0;
  double _annualIncome = 0;
  bool _remindersEnabled = true;

  // IRS 2026 rates
  static const double mileageRate = 0.70;
  static const double homeOfficeRate = 5.0;
  static const int homeOfficeMax = 300;
  static const double selfEmploymentTaxRate = 0.153;
  static const double estimatedTaxRate = 0.25;

  // Getters
  bool get mileageEnabled => _mileageEnabled;
  int get mileageEstimate => _mileageEstimate;
  double get mileageValue => _mileageEstimate * mileageRate;
  int get homeOfficeSqft => _homeOfficeSqft;
  int get homeOfficeValue => (_homeOfficeSqft * homeOfficeRate).toInt();
  double get annualIncome => _annualIncome;
  bool get remindersEnabled => _remindersEnabled;

  // Quarterly tax deadlines
  static final _quarterlyDeadlines = [
    Quarter(1, 4, 'Q1 (Jan–Mar)'),
    Quarter(2, 6, 'Q2 (Apr–May)'),
    Quarter(3, 9, 'Q3 (Jun–Aug)'),
    Quarter(4, 1, 'Q4 (Sep–Dec)'),
  ];

  List<Quarter> get upcomingDeadlines {
    final now = DateTime.now();
    final results = <Quarter>[];
    for (final q in _quarterlyDeadlines) {
      final date = DateTime(now.year, q.month, q.day);
      if (date.isBefore(now)) {
        final nextYear = DateTime(now.year + 1, q.month, q.day);
        results.add(q.copyWithDate(nextYear));
      } else {
        results.add(q.copyWithDate(date));
      }
    }
    results.sort((a, b) => a.date.compareTo(b.date));
    return results;
  }

  Quarter get nextDeadline => upcomingDeadlines.first;
  int get daysUntilNextDeadline => nextDeadline.date.difference(DateTime.now()).inDays;

  String get nextDeadlineUrgency {
    final days = daysUntilNextDeadline;
    if (days <= 7) return 'URGENT';
    if (days <= 21) return 'DUE SOON';
    if (days <= 45) return 'Upcoming';
    return 'On track';
  }

  // Estimated quarterly payment
  double get estimatedQuarterlyPayment {
    if (_annualIncome <= 0) return 0;
    return (_annualIncome * estimatedTaxRate) / 4;
  }

  double get estimatedTotalTax => _annualIncome * estimatedTaxRate;

  // Annual tax deadline
  int get daysUntilTaxDeadline {
    final now = DateTime.now();
    final deadline = DateTime(now.year, 4, 15);
    if (now.isAfter(deadline)) {
      return DateTime(now.year + 1, 4, 15).difference(now).inDays;
    }
    return deadline.difference(now).inDays;
  }

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

  // Deduction discovery
  List<DeductionTip> get missingDeductions {
    final tips = <DeductionTip>[];
    final monthlyMi = MileageLog.monthlyMiles();
    if (monthlyMi < 100) {
      tips.add(DeductionTip(
        title: 'Mileage — \$0.70/mile',
        description: monthlyMi > 0
            ? 'You logged $monthlyMi mi this month = \$${(monthlyMi * 0.70).toStringAsFixed(0)}. Most freelancers drive 200+ mi/mo. Log every trip!'
            : 'Every business mile is worth \$0.70. 200 mi/mo = \$1,680/year. Start logging trips.',
        action: 'Log a trip',
        icon: '🚗',
      ));
    }
    if (_homeOfficeSqft == 0) {
      tips.add(DeductionTip(
        title: 'Home Office — up to \$1,500/yr',
        description: 'IRS simplified method: \$5 per sq ft for dedicated workspace. No receipts needed — just measure your desk area.',
        action: 'Set up home office',
        icon: '🏠',
      ));
    }
    if (_annualIncome > 0 && _annualIncome > 50000) {
      tips.add(DeductionTip(
        title: 'SEP-IRA — reduce taxable income',
        description: 'You can contribute up to 25% of your net earnings to a SEP-IRA. On \$80K income, that\'s up to \$16K in tax-deferred savings.',
        action: 'Learn more',
        icon: '💰',
      ));
    }
    tips.add(DeductionTip(
      title: 'Health insurance premiums',
      description: 'Self-employed? Your health insurance premiums are 100% deductible — including dental and long-term care.',
      action: 'Add to tracker',
      icon: '🏥',
    ));
    tips.add(DeductionTip(
      title: 'Phone & internet',
      description: 'The business portion of your phone bill and internet is deductible. Estimate: 50% of monthly bills = easy money.',
      action: 'Add expense',
      icon: '📱',
    ));
    return tips;
  }

  // Total missed value estimate
  double get missedDeductionValue {
    double total = 0;
    final monthlyMi = MileageLog.monthlyMiles();
    if (monthlyMi < 100) total += 1680; // ~potential missed mileage
    if (_homeOfficeSqft == 0) total += 1500;
    if (_annualIncome > 50000) total += _annualIncome * 0.05;
    total += _annualIncome * 0.02; // phone/internet rough
    return total;
  }

  void init() {
    final box = Hive.box('settings');
    _mileageEnabled = box.get(_mileageKey, defaultValue: false);
    _mileageEstimate = box.get(_mileageMilesKey, defaultValue: 0);
    _homeOfficeSqft = box.get(_homeOfficeKey, defaultValue: 0);
    _annualIncome = (box.get(_incomeKey, defaultValue: 0) as num).toDouble();
    _remindersEnabled = box.get(_remindersKey, defaultValue: true);
  }

  void refresh() {
    init();
    notifyListeners();
  }

  void toggleMileage() {
    _mileageEnabled = !_mileageEnabled;
    if (_mileageEnabled && _mileageEstimate == 0) _mileageEstimate = 300;
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

  void setAnnualIncome(double income) {
    _annualIncome = income;
    Hive.box('settings').put(_incomeKey, income);
    notifyListeners();
  }

  void toggleReminders() {
    _remindersEnabled = !_remindersEnabled;
    Hive.box('settings').put(_remindersKey, _remindersEnabled);
    notifyListeners();
  }
}

class Quarter {
  final int month;
  final int day;
  final String label;
  final DateTime date;

  Quarter(this.month, this.day, this.label, [DateTime? date])
      : date = date ?? DateTime(DateTime.now().year, month, day);

  Quarter copyWithDate(DateTime newDate) => Quarter(month, day, label, newDate);
}

class DeductionTip {
  final String title;
  final String description;
  final String action;
  final String icon;

  DeductionTip({
    required this.title,
    required this.description,
    required this.action,
    required this.icon,
  });
}
