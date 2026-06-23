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

    final monthCount = receipts.monthlyCount;
    final monthTotal = receipts.monthlyTotal;

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
                  style: TextStyle(
                    color: sub.isPro ? AppTheme.green : AppTheme.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Tax countdown
          _buildTaxCountdown(insights),
          const SizedBox(height: 16),

          // Monthly summary
          _buildMonthlySummary(monthCount, monthTotal),
          const SizedBox(height: 8),

          // Hook: mileage
          _buildInsightCard(
            icon: Icons.directions_car,
            iconColor: AppTheme.orange,
            title: 'Mileage Tracking',
            subtitle: insights.mileageEstimate > 0
                ? 'Last month you drove ~${insights.mileageEstimate} mi. If tracked, worth \$${insights.mileageValue.toStringAsFixed(0)} in deductions'
                : 'Enable mileage tracking. Save \$500–\$2,000/yr automatically.',
            actionLabel: insights.mileageEnabled ? 'Active ✓' : 'Enable',
            enabled: insights.mileageEnabled,
            onTap: () => _toggleMileage(insights),
          ),
          const SizedBox(height: 8),

          // Hook: home office
          _buildInsightCard(
            icon: Icons.home_work,
            iconColor: AppTheme.purple,
            title: 'Home Office Deduction',
            subtitle: insights.homeOfficeSqft > 0
                ? '${insights.homeOfficeSqft} sq ft × \$5 = \$${insights.homeOfficeValue}/yr'
                : 'Do you have a dedicated workspace? IRS allows \$5/sq ft.',
            actionLabel: insights.homeOfficeSqft > 0 ? '\$${insights.homeOfficeValue}/yr' : 'Set Up',
            enabled: insights.homeOfficeSqft > 0,
            onTap: () => _showHomeOfficeDialog(insights),
          ),
          const SizedBox(height: 8),

          // Hook: recurring expenses
          _buildInsightCard(
            icon: Icons.repeat,
            iconColor: AppTheme.teal,
            title: 'Recurring Expenses',
            subtitle: insights.recurringCount > 0
                ? '${insights.recurringCount} recurring found · ~\$${insights.recurringMonthly.toStringAsFixed(0)}/mo'
                : 'Adobe, Dropbox, phone bill... Are you deducting these?',
            actionLabel: insights.recurringCount > 0 ? 'Review' : 'Enable',
            enabled: insights.recurringCount > 0,
            onTap: () {},
          ),
          const SizedBox(height: 8),

          // Hook: industry comparison
          _buildInsightCard(
            icon: Icons.insights,
            iconColor: AppTheme.blue,
            title: 'Industry Average',
            subtitle: monthCount > 0
                ? 'You\'ve deducted \$${receipts.monthlyTotal.toStringAsFixed(0)} this year · Avg freelancer \$4,200'
                : 'Freelancers like you average \$4,200/yr in deductions.',
            actionLabel: 'Details',
            enabled: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTaxCountdown(InsightsProvider insights) {
    final days = insights.daysUntilTaxDeadline;
    final color = days <= 30 ? AppTheme.red : days <= 60 ? AppTheme.orange : AppTheme.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days > 0 ? '$days days until tax deadline' : 'Tax season is here!',
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  days > 30
                      ? 'Don\'t wait until the last minute. Start organizing now.'
                      : 'At this rate, you could miss ~\$1,200 in deductions.',
                  style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(int count, double total) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.blue, AppTheme.blueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppTheme.blue.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
        ],
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

  Widget _buildInsightCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionLabel,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.separator),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
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
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: enabled ? AppTheme.green : AppTheme.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMileage(InsightsProvider insights) {
    if (insights.mileageEnabled) return;
    setState(() {});
    insights.toggleMileage();
  }

  void _showHomeOfficeDialog(InsightsProvider insights) {
    final controller = TextEditingController(
      text: insights.homeOfficeSqft > 0 ? insights.homeOfficeSqft.toString() : '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Home Office'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Do you have a dedicated workspace? Enter square footage:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 200',
                suffixText: 'sq ft',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'IRS simplified: \$5/sq ft, max 300 sq ft (\$1,500/yr)',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (insights.homeOfficeSqft > 0)
            TextButton(
              onPressed: () {
                insights.setHomeOfficeSqft(0);
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final sqft = int.tryParse(controller.text);
              if (sqft != null && sqft > 0) {
                insights.setHomeOfficeSqft(sqft > 300 ? 300 : sqft);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
