import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../widgets/paywall_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          // Subscription card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: sub.isPro ? AppTheme.green.withValues(alpha: 0.15) : AppTheme.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sub.isPro ? 'PRO' : 'FREE',
                            style: TextStyle(
                              color: sub.isPro ? AppTheme.green : AppTheme.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (!sub.isPro)
                          Text(
                            '${sub.receiptCount} of ${AppConstants.freeReceiptLimit}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!sub.isPro) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: sub.usageFraction,
                          backgroundColor: AppTheme.separator,
                          color: AppTheme.blue,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${sub.remainingFree} free receipts remaining',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _showPaywall(context),
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: const Text('Upgrade to Pro'),
                        ),
                      ),
                    ] else ...[
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppTheme.green, size: 18),
                          SizedBox(width: 8),
                          Text('Pro — Unlimited receipts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Menu items
          ..._buildMenuSection([
            _MenuItem(Icons.history, 'Export History', () {}),
            _MenuItem(Icons.settings_outlined, 'App Settings', () {}),
            _MenuItem(Icons.help_outline, 'Help & Support', () {}),
            _MenuItem(Icons.lock_outline, 'Privacy Policy', () {}),
            _MenuItem(Icons.description_outlined, 'Terms of Service', () {}),
          ]),

          const SizedBox(height: 32),
          const Center(
            child: Column(
              children: [
                Text('SnapDeduct v1.0.0', style: TextStyle(color: AppTheme.textTertiary, fontSize: 13)),
                SizedBox(height: 4),
                Text('Made with ❤️ for freelancers', style: TextStyle(color: AppTheme.textTertiary, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaywallSheet(),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem(this.icon, this.title, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
      onTap: onTap,
    );
  }
}

List<Widget> _buildMenuSection(List<_MenuItem> items) {
  return [
    const SizedBox(height: 8),
    Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: items.map((item) {
        final idx = items.indexOf(item);
        return Column(
          children: [
            if (idx > 0) const Divider(height: 1, indent: 56),
            item,
          ],
        );
      }).toList()),
    ),
  ];
}
