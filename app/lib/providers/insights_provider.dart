import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/mileage_log.dart';
import '../services/irs_config.dart';

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

  // ── IRS-Sourced Values (auto-updated via IrsConfig) ──

  double get irsMileageRate => IrsConfig.mileageRate;
  double get irsHomeOfficeRate => IrsConfig.homeOfficeRate;
  int get irsHomeOfficeMaxSqft => IrsConfig.homeOfficeMaxSqft;
  double get selfEmploymentTaxRate => IrsConfig.seTaxRate;
  double get estimatedEffectiveRate => IrsConfig.estimatedEffectiveRate;

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

  /// Estimated quarterly payment: (income × 25%)/4.
  /// 25% is a blended estimate for federal income tax only.
  /// Actual: ~21.5% at $50K, ~27.3% at $100K, ~28.9% at $150K.
  /// See SE Tax card below for the separate 15.3% self-employment tax.
  /// 2026 SS wage base: $184,500 (Pub 15).
  /// Estimate only — consult a tax professional.
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
        description: 'You can contribute up to 25% of your net earnings to a SEP-IRA. On \$80K income, that\'s up to \$16K in tax-deferred savings. No paperwork — just open an account.',
        action: 'See limits',
        icon: '💼',
      ));
      tips.add(DeductionTip(
        title: 'Solo 401(k) vs SEP-IRA (IRS Pub 560)',
        description: 'Solo 401(k) often beats SEP-IRA by \$6K+\$ at lower incomes. Under \$60K: Solo 401(k) allows higher contributions. Over \$100K: SEP-IRA is simpler but Solo 401(k) still caps higher.',
        action: 'Compare options',
        icon: '🏦',
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
    tips.add(DeductionTip(
      title: 'Business vs Personal Expenses (IRS Pub 535)',
      description: 'You can ONLY deduct the business portion of mixed expenses. That Netflix subscription? No. That Adobe license for client work? Yes — the business % of it.',
      action: 'Learn the rules',
      icon: '⚖️',
    ));
    tips.add(DeductionTip(
      title: 'Separate Bank Accounts (IRS Pub 583)',
      description: 'IRS strongly recommends separate business accounts. Commingling is a top audit trigger. Even a free checking account counts if used exclusively for business.',
      action: 'Why it matters',
      icon: '🏦',
    ));
    if (_annualIncome > 20000) {
      tips.add(DeductionTip(
        title: 'Contractor vs Employee (IRS Pub 15-A)',
        description: 'Hire freelancers? Misclassifying workers as 1099 when they should be W-2 carries penalties up to 100% of unpaid taxes. Use the IRS 20-factor test.',
        action: 'Understand classification',
        icon: '👥',
      ));
    }
    // 2026 tax law changes (P.L. 119-21)
    tips.add(DeductionTip(
      title: '🆕 QBI Deduction — 20% Off Your Income (Form 8995)',
      description: 'The Qualified Business Income deduction lets you deduct 20% of your net business income. On \$80K profit, that\'s \$16K right off the top. Made permanent by P.L. 119-21.',
      action: 'Calculate yours',
      icon: '📉',
    ));
    tips.add(DeductionTip(
      title: '🆕 2026: Overtime Pay Deduction',
      description: 'Up to \$12,500 of overtime-equivalent pay may now be deducted from income for 2025-2028. Applies to gig workers too. P.L. 119-21.',
      action: 'Learn more',
      icon: '🕐',
    ));
    tips.add(DeductionTip(
      title: '🆕 2026: Tips Are Tax-Free',
      description: 'Self-employed workers can now deduct qualified tips from income. If you receive tips for your work, track them — they may be fully deductible. P.L. 119-21.',
      action: 'Track tips',
      icon: '💵',
    ));
    tips.add(DeductionTip(
      title: '🆕 2026: 100% Bonus Depreciation',
      description: 'Buy equipment for your business? 100% first-year expensing is now permanent. Camera, laptop, car — write off the full cost immediately. IRS Pub 946.',
      action: 'Track assets',
      icon: '🏗️',
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
