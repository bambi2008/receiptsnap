import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/receipt_provider.dart';
import '../providers/subscription_provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sub.isPro ? AppTheme.green.withValues(alpha: 0.15) : AppTheme.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(sub.isPro ? 'PRO' : 'FREE',
                          style: TextStyle(color: sub.isPro ? AppTheme.green : AppTheme.orange, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ),
                    const Spacer(),
                    if (!sub.isPro)
                      Text('${sub.receiptCount} of ${AppConstants.freeReceiptLimit}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  ]),
                  const SizedBox(height: 12),
                  if (!sub.isPro) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: sub.usageFraction, backgroundColor: AppTheme.separator, color: AppTheme.blue, minHeight: 6),
                    ),
                    const SizedBox(height: 8),
                    Text('${sub.remainingFree} free receipts remaining',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: FilledButton.icon(
                      onPressed: () => _showPaywall(context),
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Upgrade to Pro — \$89.99/year'),
                    )),
                  ] else ...[
                    const Row(children: [
                      Icon(Icons.check_circle, color: AppTheme.green, size: 18),
                      SizedBox(width: 8),
                      Text('Pro — All features unlocked', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ]),
                  ],
                ]),
              ),
            ),
          ),

          // Pro features preview (only in free tier)
          if (!sub.isPro) _buildProTeaser(),

          // Main menu
          ..._buildMenuSection([
            _MenuItem(Icons.file_download_outlined, 'Export All Receipts', () => _exportAll(context)),
            _MenuItem(Icons.notifications_outlined, 'Daily Mileage Reminder (8 PM)', () => _toggleMileageReminder(context)),
            _MenuItem(Icons.info_outline, 'Tax Deadlines & Info', () => _showReminderInfo(context)),
            _MenuItem(Icons.info_outline, 'Disclaimer & Sources', () => _showDisclaimer(context)),
          ]),

          // Legal
          ..._buildMenuSection([
            _MenuItem(Icons.description_outlined, 'Privacy Policy', () => _openLocalAsset(context, 'assets/privacy.html', 'Privacy Policy')),
            _MenuItem(Icons.gavel_outlined, 'Terms of Service', () => _openLocalAsset(context, 'assets/terms.html', 'Terms of Service')),
          ]),

          const SizedBox(height: 24),
          const Center(
            child: Column(children: [
              Text('SnapDeduct v${AppConstants.appVersion}', style: TextStyle(color: AppTheme.textTertiary, fontSize: 13)),
              SizedBox(height: 4),
              Text('Made with ❤️ for freelancers', style: TextStyle(color: AppTheme.textTertiary, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Pro Teaser ──

  Widget _buildProTeaser() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.blue.withValues(alpha: 0.05), AppTheme.blueDark.withValues(alpha: 0.05)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.blue.withValues(alpha: 0.15)),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🔒 Pro Features', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        SizedBox(height: 8),
        Text('• Unlimited receipt scans', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        Text('• Industry comparison benchmarks', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        Text('• Priority email support', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ]),
      ),
    );
  }

  // ── Actions ──

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

  void _toggleMileageReminder(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final granted = await NotificationService.requestPermission();
    if (!granted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enable notifications in Settings to receive mileage reminders')),
      );
      return;
    }
    await NotificationService.scheduleMileageReminder();
    messenger.showSnackBar(
      const SnackBar(content: Text('✅ Daily reminder set for 8 PM')),
    );
  }

  void _showReminderInfo(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Quarterly Tax Deadlines'),
      content: const Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Estimated tax payments are due:', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text('• Q1 (Jan–Mar): April 15'),
        Text('• Q2 (Apr–May): June 15'),
        Text('• Q3 (Jun–Aug): September 15'),
        Text('• Q4 (Sep–Dec): January 15'),
        SizedBox(height: 12),
        Text('Source: IRS Publication 505, Form 1040-ES.', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textSecondary)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Disclaimer'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'SnapDeduct provides educational estimates based on IRS guidelines. '
            'It is not tax, legal, or financial advice. '
            'Consult a qualified tax professional for your specific situation. '
            'Sources: IRS Publications 463, 505, 535, 587; IRC §1401, §162, §274.',
            style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Text('IRS Sources Referenced:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...['Pub 463 — Travel, Gift, and Car Expenses (mileage)',
                'Pub 505 — Tax Withholding and Estimated Tax',
                'Pub 535 — Business Expenses',
                'Pub 583 — Starting a Business and Keeping Records',
                'Pub 587 — Business Use of Your Home',
                'IRC §1401 — Self-Employment Tax',
                'IRC §162 — Trade or Business Expenses',
                'IRC §274 — Disallowance of Certain Expenses',
                'IRC §6651 — Failure to File/Pay Penalties',
                'IRC §6654 — Estimated Tax Underpayment',
          ].map((s) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(s, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)))),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ));
  }

  void _openLocalAsset(BuildContext context, String assetPath, String title) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _LocalHtmlViewer(assetPath: assetPath, title: title)));
  }
}

// ── In-app HTML viewer for bundled assets ──

class _LocalHtmlViewer extends StatefulWidget {
  final String assetPath;
  final String title;
  const _LocalHtmlViewer({required this.assetPath, required this.title});

  @override
  State<_LocalHtmlViewer> createState() => _LocalHtmlViewerState();
}

class _LocalHtmlViewerState extends State<_LocalHtmlViewer> {
  String _html = 'Loading...';

  @override
  void initState() {
    super.initState();
    rootBundle.loadString(widget.assetPath).then((s) => setState(() => _html = s));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SelectableText(_html.replaceAll(RegExp(r'<[^>]+>'), '\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim(),
            style: const TextStyle(fontSize: 14, height: 1.5)),
      ),
    );
  }
}

// ── Menu Components ──

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
