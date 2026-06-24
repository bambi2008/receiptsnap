import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/receipt_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/insights_provider.dart';
import '../config/theme.dart';

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
            subtitle: insights.mileageEnabled
                ? '~${insights.mileageEstimate} mi/mo · \$${insights.mileageValue.toStringAsFixed(0)}/yr'
                : '\$0.70/mile. 300 mi/mo = \$2,520/yr. Enable now.',
            actionLabel: insights.mileageEnabled ? 'Active' : 'Enable',
            enabled: insights.mileageEnabled,
            onTap: () => insights.mileageEnabled ? _showMileageDialog(insights) : insights.toggleMileage(),
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
              'Est. payment: \$${insights.estimatedQuarterlyPayment.toStringAsFixed(0)}',
              style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Based on \$${(insights.annualIncome > 0 ? (insights.annualIncome ~/ 1000).toString() : '?')}K annual income · 25% effective rate',
              style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 12),
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

  void _showMileageDialog(InsightsProvider insights) {
    final ctrl = TextEditingController(text: insights.mileageEstimate.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Monthly Mileage'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('How many miles do you drive for business each month?'),
          const SizedBox(height: 12),
          TextField(controller: ctrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(suffixText: 'miles', hintText: '300', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          Text('IRS rate: \$0.70/mile. 300 mi × 12 = \$2,520/year.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ]),
        actions: [
          TextButton(onPressed: () { insights.toggleMileage(); Navigator.pop(context); }, child: const Text('Disable')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final v = int.tryParse(ctrl.text);
            if (v != null && v > 0) insights.setMileageEstimate(v);
            Navigator.pop(context);
          }, child: const Text('Save')),
        ],
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
