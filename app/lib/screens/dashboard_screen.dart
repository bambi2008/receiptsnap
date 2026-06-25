import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/receipt_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/insights_provider.dart';
import '../config/theme.dart';
import '../services/mileage_log.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final receipts = context.watch<ReceiptProvider>();
    final insights = context.watch<InsightsProvider>();
    final sub = context.watch<SubscriptionProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('SnapDeduct'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sub.isPro ? AppTheme.green.withValues(alpha: 0.15) : AppTheme.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sub.isPro ? 'PRO' : 'Free: ${sub.remainingFree}',
                  style: TextStyle(color: sub.isPro ? AppTheme.green : AppTheme.blue, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _buildQuarterlyTaxCard(insights),
          const SizedBox(height: 12),
          _buildSETaxCard(insights),
          const SizedBox(height: 12),
          _buildMonthlySummary(receipts.monthlyCount, receipts.monthlyTotal),
          const SizedBox(height: 12),

          // Missed deductions alert
          if (insights.missedDeductionValue > 0)
            _buildMissedDeductionsBanner(insights),
          const SizedBox(height: 8),

          _buildInsightCard(
            icon: Icons.directions_car,
            iconColor: AppTheme.orange,
            title: 'Mileage Tracking',
            subtitle: () {
              final monthlyMi = MileageLog.monthlyMiles();
              if (monthlyMi > 0) {
                return '${MileageLog.monthlyTripCount()} trips · $monthlyMi mi · \$${MileageLog.monthlyValue().toStringAsFixed(0)}/mo';
              }
              return '\$0.70/mile. Log your first trip → save on taxes.';
            }(),
            actionLabel: MileageLog.monthlyMiles() > 0 ? '+\$${MileageLog.monthlyValue().toStringAsFixed(0)}' : 'Log Trip',
            enabled: MileageLog.monthlyMiles() > 0,
            onTap: () => _showMileageMenu(),
          ),
          const SizedBox(height: 8),
          _buildInsightCard(
            icon: Icons.home_work,
            iconColor: AppTheme.purple,
            title: 'Home Office',
            subtitle: insights.homeOfficeSqft > 0
                ? '${insights.homeOfficeSqft} sq ft · \$${insights.homeOfficeValue}/yr'
                : '\$5/sq ft. No receipts needed.',
            actionLabel: insights.homeOfficeSqft > 0 ? '\$${insights.homeOfficeValue}' : 'Set Up',
            enabled: insights.homeOfficeSqft > 0,
            onTap: () => _showHomeOfficeDialog(insights),
          ),
          const SizedBox(height: 8),
          _buildInsightCard(
            icon: Icons.repeat,
            iconColor: AppTheme.teal,
            title: 'Recurring Expenses',
            subtitle: insights.recurringCount > 0
                ? '${insights.recurringCount} tracked · \$${insights.recurringMonthly.toStringAsFixed(0)}/mo'
                : 'Subscriptions, phone, internet — are you deducting these?',
            actionLabel: insights.recurringCount > 0 ? 'Review' : 'Add',
            enabled: insights.recurringCount > 0,
            onTap: () => _showRecurringDialog(insights),
          ),
          const SizedBox(height: 8),
          _buildInsightCard(
            icon: Icons.insights,
            iconColor: AppTheme.blue,
            title: 'Deduction Discovery',
            subtitle: '${insights.missingDeductions.length} deductions you might be missing',
            actionLabel: 'Explore',
            enabled: false,
            onTap: () => _showDiscoveryDialog(insights),
          ),
          const SizedBox(height: 8),
          _buildInsightCard(
            icon: Icons.trending_up,
            iconColor: AppTheme.indigo,
            title: 'Industry Average',
            subtitle: receipts.monthlyCount > 0
                ? 'You\'ve deducted \$${receipts.monthlyTotal.toStringAsFixed(0)} · Avg freelancer \$4,200/yr'
                : 'Freelancers like you average \$4,200/yr in deductions',
            actionLabel: receipts.monthlyCount > 0 ? '${(receipts.monthlyTotal / 42).toStringAsFixed(0)}%' : 'Goal',
            enabled: receipts.monthlyCount > 0,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ── Quarterly Tax Card ──
  Widget _buildQuarterlyTaxCard(InsightsProvider insights) {
    final days = insights.daysUntilNextDeadline;
    final urgency = insights.nextDeadlineUrgency;
    final isUrgent = urgency == 'URGENT' || urgency == 'DUE SOON';
    final color = isUrgent
        ? (urgency == 'URGENT' ? AppTheme.red : AppTheme.orange)
        : AppTheme.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(urgency, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              Icon(Icons.notifications_active, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insights.nextDeadline.label,
            style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            '$days days until estimated tax is due',
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (insights.estimatedQuarterlyPayment > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Est. payment: \$${insights.estimatedQuarterlyPaymentFormatted}  (estimate)',
              style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Based on \$${(insights.annualIncome > 0 ? (insights.annualIncome ~/ 1000).toString() : '?')}K income · ~25% effective rate',
              style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              'Source: IRS Pub 505, Form 1040-ES. Estimate only — not tax advice.',
              style: TextStyle(color: color.withValues(alpha: 0.4), fontSize: 10, fontStyle: FontStyle.italic),
            ),
          ] else ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showIncomeDialog(insights),
              child: Text(
                'Tap to set your income → get exact estimates',
                style: TextStyle(color: color, fontSize: 13, decoration: TextDecoration.underline, decorationColor: color),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Missed Deductions Banner ──
  Widget _buildMissedDeductionsBanner(InsightsProvider insights) {
    return GestureDetector(
      onTap: () => _showDiscoveryDialog(insights),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.red.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.red.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            const Text('💸', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You may be missing ~\$${insights.missedDeductionValue.toStringAsFixed(0)}/yr in deductions',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.text),
                  ),
                  const SizedBox(height: 2),
                  const Text('Tap to see what you\'re leaving on the table',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  // ── SE Tax Explanation Card ──
  Widget _buildSETaxCard(InsightsProvider insights) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.indigo.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.indigo.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.info_outline, color: AppTheme.indigo, size: 18),
            const SizedBox(width: 8),
            const Text('Self-Employment Tax: 15.3%', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            if (insights.annualIncome > 0)
              Text('~\$${insights.estimatedSETax.toStringAsFixed(0)}/yr',
                  style: TextStyle(color: AppTheme.indigo, fontWeight: FontWeight.w600, fontSize: 14)),
          ]),
          const SizedBox(height: 8),
          Text(
            '12.4% Social Security + 2.9% Medicare on your net earnings. '
            'This is IN ADDITION to income tax. Most new freelancers are surprised by this bill.',
            style: TextStyle(color: AppTheme.indigo.withValues(alpha: 0.7), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Source: IRC §1401; IRS Schedule SE. Estimate only.',
            style: TextStyle(color: AppTheme.indigo.withValues(alpha: 0.35), fontSize: 10, fontStyle: FontStyle.italic),
          ),
          if (insights.annualIncome <= 0) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showIncomeDialog(insights),
              child: Text('Tap to set income → see your estimated SE tax',
                  style: TextStyle(color: AppTheme.indigo, fontSize: 12, decoration: TextDecoration.underline, decorationColor: AppTheme.indigo)),
            ),
          ],
        ],
      ),
    );
  }

  // ── Monthly Summary ──
  Widget _buildMonthlySummary(int count, double total) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.blue, AppTheme.blueDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppTheme.blue.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('THIS MONTH', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('$count receipts · \$${total.toStringAsFixed(2)} deducted',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── Insight Card ──
  Widget _buildInsightCard({
    required IconData icon, required Color iconColor, required String title,
    required String subtitle, required String actionLabel, required bool enabled, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.separator)),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: enabled ? AppTheme.green.withValues(alpha: 0.1) : AppTheme.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(actionLabel, style: TextStyle(color: enabled ? AppTheme.green : AppTheme.blue, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialogs ──

  void _showIncomeDialog(InsightsProvider insights) {
    final ctrl = TextEditingController(text: insights.annualIncome > 0 ? insights.annualIncome.toStringAsFixed(0) : '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Your Annual Income'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Enter your estimated annual self-employment income:'),
          const SizedBox(height: 12),
          TextField(controller: ctrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(prefixText: '\$ ', hintText: '80000', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          Text('Used to calculate estimated quarterly taxes at 25% effective rate + 15.3% self-employment tax.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final v = double.tryParse(ctrl.text);
            if (v != null && v > 0) insights.setAnnualIncome(v);
            Navigator.pop(context);
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  void _showMileageMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Mileage Log', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('\$0.70/mile IRS rate (Pub 463) · ${MileageLog.monthlyTripCount()} trips this month · ${MileageLog.monthlyMiles()} mi\n${MileageLog.annualMiles()} mi YTD · \$${MileageLog.annualValue().toStringAsFixed(0)}/yr',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () { Navigator.pop(context); _showAddTripDialog(); },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Log a Trip'),
              ),
            ),
            const SizedBox(height: 8),
            if (MileageLog.monthlyMiles() > 0)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () { Navigator.pop(context); _showTripHistory(); },
                  icon: const Icon(Icons.history, size: 20),
                  label: Text('View History (${MileageLog.load().length} trips)'),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddTripDialog() {
    final milesCtrl = TextEditingController();
    final purposeCtrl = TextEditingController();
    final destCtrl = TextEditingController();
    final odoCtrl = TextEditingController();
    final quickPresets = [5.0, 12.0, 25.0, 50.0];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Log a Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Miles driven:', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: quickPresets.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    label: Text('${m.toInt()} mi'),
                    onPressed: () {
                      milesCtrl.text = m.toInt().toString();
                      setDialogState(() {});
                    },
                  ),
                )).toList(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: milesCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'e.g. 15', suffixText: 'miles', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: purposeCtrl,
                decoration: const InputDecoration(hintText: 'Purpose (e.g. client meeting)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: destCtrl,
                decoration: const InputDecoration(hintText: 'Destination (IRS recommended)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: odoCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Odometer reading (optional)', border: OutlineInputBorder()),
              ),
              if (milesCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('IRS value: \$${(double.tryParse(milesCtrl.text) ?? 0) * MileageLog.irsMileageRate}',
                    style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final miles = double.tryParse(milesCtrl.text);
                if (miles != null && miles > 0) {
                  MileageLog.addTrip(
                    miles: miles,
                    purpose: purposeCtrl.text,
                    destination: destCtrl.text,
                    odometerStart: int.tryParse(odoCtrl.text),
                  );
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTripHistory() {
    final trips = MileageLog.load();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [
              const Text('Trip History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${trips.length} trips', style: const TextStyle(color: AppTheme.textSecondary)),
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: trips.isEmpty
                  ? const Center(child: Text('No trips logged yet', style: TextStyle(color: AppTheme.textSecondary)))
                  : ListView.builder(
                      itemCount: trips.length,
                      itemBuilder: (_, i) {
                        final t = trips[i];
                        return Dismissible(
                          key: Key('trip_${t.date.toIso8601String()}_$i'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: AppTheme.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            MileageLog.deleteTrip(i);
                            setState(() {});
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.orange.withValues(alpha: 0.12),
                              child: const Icon(Icons.directions_car, color: AppTheme.orange, size: 20),
                            ),
                            title: Text(t.purpose, style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(t.destination.isNotEmpty
                                ? '${t.date.month}/${t.date.day} · ${t.destination} · ${t.miles} mi'
                                : '${t.date.month}/${t.date.day} · ${t.miles} mi'),
                            trailing: Text('\$${(t.miles * 0.70).toStringAsFixed(2)}',
                                style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.w600)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHomeOfficeDialog(InsightsProvider insights) {
    final ctrl = TextEditingController(text: insights.homeOfficeSqft > 0 ? insights.homeOfficeSqft.toString() : '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Home Office'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Do you have a dedicated workspace? Enter square footage:'),
          const SizedBox(height: 12),
          TextField(controller: ctrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'e.g. 200', suffixText: 'sq ft', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          Text('IRS simplified: \$5/sq ft, max 300 sq ft (\$1,500/yr). No receipts needed.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ]),
        actions: [
          if (insights.homeOfficeSqft > 0) TextButton(onPressed: () { insights.setHomeOfficeSqft(0); Navigator.pop(context); }, child: const Text('Clear')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final sqft = int.tryParse(ctrl.text);
            if (sqft != null && sqft > 0) insights.setHomeOfficeSqft(sqft > 300 ? 300 : sqft);
            Navigator.pop(context);
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  void _showRecurringDialog(InsightsProvider insights) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Recurring Expenses'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Common deductions freelancers forget:'),
          const SizedBox(height: 12),
          ...['📱 Phone bill (business %)', '🌐 Internet (business %)', '💻 Software subscriptions', '☁️ Cloud storage', '📧 Email / domain hosting']
              .map((t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: const TextStyle(fontSize: 14)))),
          const SizedBox(height: 12),
          Text('Pro tip: estimate the business-use % and deduct that portion.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
      ),
    );
  }

  void _showDiscoveryDialog(InsightsProvider insights) {
    final tips = insights.missingDeductions;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('💡 Deductions You May Be Missing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Estimated missed value: ~\$${insights.missedDeductionValue.toStringAsFixed(0)}/year',
                style: const TextStyle(color: AppTheme.red, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: tips.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final t = tips[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(t.icon, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
                        ]),
                        const SizedBox(height: 6),
                        Text(t.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(t.action)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
