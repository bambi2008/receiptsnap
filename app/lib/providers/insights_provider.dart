import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/mileage_log.dart';

/// IRS-sourced constants and estimates for SnapDeduct.
/// All estimates are clearly labeled. See inline citations.
class InsightsProvider extends ChangeNotifier {
  static const _homeOfficeKey = 'home_office_sqft';
  static const _incomeKey = 'annual_income';
  static const _remindersKey = 'quarterly_reminders_enabled';
  static const _disclaimerKey = 'disclaimer_accepted';

  int _homeOfficeSqft = 0;
  double _annualIncome = 0;
  bool _remindersEnabled = true;
  bool _disclaimerAccepted = false;

  // ── IRS-Sourced Constants ──

  /// IRS 2025 standard mileage rate: $0.70/mile
  /// Source: IRS Publication 463, Chapter 4
  static const double irsMileageRate = 0.70;

  /// IRS simplified home office: $5/sq ft, max 300 sq ft ($1,500/yr)
  /// Source: IRS Publication 587, "Simplified Method"
  static const double irsHomeOfficeRate = 5.0;
  static const int irsHomeOfficeMaxSqft = 300;

  /// Self-employment tax: 12.4% Social Security + 2.9% Medicare = 15.3%
  /// Source: IRC §1401; IRS Publication 334
  static const double selfEmploymentTaxRate = 0.153;

  /// Effective income tax rate estimate for $50K–$150K filers.
  /// ESTIMATE ONLY — actual rate depends on total income, deductions,
  /// filing status, and state. This is a blended approximation.
  /// Source: 2025 tax brackets (IRS Rev. Proc. 2024-40)
  static const double estimatedEffectiveRate = 0.25;

  // ── Disclaimer ──

  bool get disclaimerAccepted => _disclaimerAccepted;

  /// Standard disclaimer text for all SnapDeduct calculations.
  static const String disclaimer = 
      'SnapDeduct provides educational estimates based on IRS guidelines. '
      'It is not tax, legal, or financial advice. '
      'Consult a qualified tax professional for your specific situation. '
      'Sources: IRS Publications 463, 535, 587; IRC §1401, §162, §274.';

  // ── Getters ──

  int get homeOfficeSqft => _homeOfficeSqft;
  int get homeOfficeValue => (_homeOfficeSqft * irsHomeOfficeRate).toInt();
  double get annualIncome => _annualIncome;
  bool get remindersEnabled => _remindersEnabled;

  /// Estimated quarterly payment: (income × 25%)/4. Estimate only.
  String get estimatedQuarterlyPaymentFormatted =>
      estimatedQuarterlyPayment > 0
          ? '\$${estimatedQuarterlyPayment.toStringAsFixed(0)}'
          : '—';

  double get estimatedQuarterlyPayment {
    if (_annualIncome <= 0) return 0;
    return (_annualIncome * estimatedEffectiveRate) / 4;
  }

  /// Estimated SE tax for the year: income × 15.3%. 
  /// Actual SE tax = net earnings × 92.35% × 15.3%.
  double get estimatedSETax {
    if (_annualIncome <= 0) return 0;
    return _annualIncome * 0.9235 * selfEmploymentTaxRate;
  }

  // ── Quarterly Deadlines ──

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
        results.add(q.copyWithDate(DateTime(now.year + 1, q.month, q.day)));
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

  int get daysUntilTaxDeadline {
    final now = DateTime.now();
    final deadline = DateTime(now.year, 4, 15);
    if (now.isAfter(deadline)) {
      return DateTime(now.year + 1, 4, 15).difference(now).inDays;
    }
    return deadline.difference(now).inDays;
  }

  // ── Deduction Discovery ──

  List<DeductionTip> get missingDeductions {
    final tips = <DeductionTip>[];
    final monthlyMi = MileageLog.monthlyMiles();
    if (monthlyMi < 100) {
      tips.add(DeductionTip(
        title: 'Mileage — \$0.70/mile (IRS Pub 463)',
        description: monthlyMi > 0
            ? 'You logged $monthlyMi mi this month = \$${(monthlyMi * irsMileageRate).toStringAsFixed(0)}. Most freelancers drive 200+ mi/mo. Log every trip!'
            : 'Every business mile is worth \$0.70. 200 mi/mo = \$1,680/year. Start logging trips.',
        action: 'Log a trip',
        icon: '🚗',
      ));
    }
    if (_homeOfficeSqft == 0) {
      tips.add(DeductionTip(
        title: 'Home Office — up to \$1,500/yr (IRS Pub 587)',
        description: 'IRS simplified method: \$5 per sq ft for dedicated workspace. No receipts needed — just measure your desk area.',
        action: 'Set up home office',
        icon: '🏠',
      ));
    }
    if (_annualIncome > 50000) {
      tips.add(DeductionTip(
        title: 'SEP-IRA — reduce taxable income (IRS Pub 560)',
        description: 'You can contribute up to 25% of your net earnings to a SEP-IRA. On \$80K income, that\'s up to \$16K in tax-deferred savings.',
        action: 'Learn more',
        icon: '💰',
      ));
    }
    tips.add(DeductionTip(
      title: 'Health insurance premiums (IRS Pub 535 Ch.6)',
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

  double get missedDeductionValue {
    double total = 0;
    final monthlyMi = MileageLog.monthlyMiles();
    if (monthlyMi < 100) total += 1680;
    if (_homeOfficeSqft == 0) total += 1500;
    if (_annualIncome > 50000) total += _annualIncome * 0.05;
    total += _annualIncome * 0.02;
    return total;
  }

  // ── Recurring Expenses ──

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

  // ── Init & Persistence ──

  void init() {
    final box = Hive.box('settings');
    _homeOfficeSqft = box.get(_homeOfficeKey, defaultValue: 0);
    _annualIncome = (box.get(_incomeKey, defaultValue: 0) as num).toDouble();
    _remindersEnabled = box.get(_remindersKey, defaultValue: true);
    _disclaimerAccepted = box.get(_disclaimerKey, defaultValue: false);
  }

  void refresh() {
    init();
    notifyListeners();
  }

  void setHomeOfficeSqft(int sqft) {
    _homeOfficeSqft = sqft.clamp(0, irsHomeOfficeMaxSqft);
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

  void acceptDisclaimer() {
    _disclaimerAccepted = true;
    Hive.box('settings').put(_disclaimerKey, true);
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
