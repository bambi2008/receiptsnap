import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/receipt_provider.dart';
import '../providers/subscription_provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../services/export_service.dart';
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
                            style: TextStyle(color: sub.isPro ? AppTheme.green : AppTheme.orange, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                          ),
                        ),
                        const Spacer(),
                        if (!sub.isPro)
                          Text('${sub.receiptCount} of ${AppConstants.freeReceiptLimit}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!sub.isPro) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: sub.usageFraction, backgroundColor: AppTheme.separator, color: AppTheme.blue, minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${sub.remainingFree} free receipts remaining', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
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
                      const Row(children: [
                        Icon(Icons.check_circle, color: AppTheme.green, size: 18),
                        SizedBox(width: 8),
                        Text('Pro — Unlimited receipts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Menu items
          ..._buildMenuSection([
            _MenuItem(Icons.file_download_outlined, 'Export All Receipts', () => _exportAll(context)),
            _MenuItem(Icons.notifications_outlined, 'Quarterly Tax Reminders', () => _showReminderSettings(context)),
            _MenuItem(Icons.help_outline, 'Help & Support', () => _openUrl(AppConstants.supportEmail.contains('@') ? 'mailto:${AppConstants.supportEmail}' : 'https://snapdeduct.com/help')),
            _MenuItem(Icons.lock_outline, 'Privacy Policy', () => _openUrl(AppConstants.privacyUrl)),
            _MenuItem(Icons.description_outlined, 'Terms of Service', () => _openUrl(AppConstants.termsUrl)),
          ]),

          const SizedBox(height: 32),
          const Center(
            child: Column(children: [
              Text('SnapDeduct v${AppConstants.appVersion}', style: TextStyle(color: AppTheme.textTertiary, fontSize: 13)),
              SizedBox(height: 4),
              Text('Made with ❤️ for freelancers', style: TextStyle(color: AppTheme.textTertiary, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const PaywallSheet());
  }

  void _exportAll(BuildContext context) async {
    final provider = context.read<ReceiptProvider>();
    final receipts = provider.search('');
    if (receipts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No receipts to export yet')));
      return;
    }
    final path = await ExportService.exportCsv(receipts);
    if (path != null) {
      await Share.shareXFiles([XFile(path)], subject: 'SnapDeduct Tax Export');
    }
  }

  void _showReminderSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quarterly Tax Reminders'),
        content: const Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Estimated tax deadlines:', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('• Q1 (Jan–Mar): April 15'),
          Text('• Q2 (Apr–May): June 15'),
          Text('• Q3 (Jun–Aug): September 15'),
          Text('• Q4 (Sep–Dec): January 15'),
          SizedBox(height: 12),
          Text('Reminders appear on your Dashboard when a deadline is approaching.'),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
        return Column(children: [
          if (idx > 0) const Divider(height: 1, indent: 56),
          item,
        ]);
      }).toList()),
    ),
  ];
}
