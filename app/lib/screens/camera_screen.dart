import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/receipt_provider.dart';
import '../providers/subscription_provider.dart';
import '../models/receipt.dart';
import '../services/ocr_service.dart';
import '../services/receipt_image_store.dart';
import '../services/tax_reminder_service.dart';
import 'tax_guide_screen.dart';
import 'tax_reminders_screen.dart';
import '../widgets/result_sheet.dart';
import '../widgets/paywall_sheet.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _captureReceipt() async {
    final sub = context.read<SubscriptionProvider>();
    if (sub.hasReachedLimit) {
      _showUpgradePrompt();
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 3000,
        maxHeight: 3000,
      );
      if (photo != null && mounted) {
        await _processImage(photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to capture: $e')));
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final sub = context.read<SubscriptionProvider>();
    if (sub.hasReachedLimit) {
      _showUpgradePrompt();
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 3000,
        maxHeight: 3000,
      );
      if (image != null && mounted) {
        await _processImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() => _isProcessing = true);

    try {
      await ReceiptImageStore.validateForOcr(imagePath);
      final ocrResult = await OcrService.processImage(imagePath);

      if (mounted) {
        setState(() => _isProcessing = false);
        final result = await showModalBottomSheet<Receipt>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ResultSheet(
            imagePath: imagePath,
            vendorName: ocrResult.vendorName,
            amount: ocrResult.amount,
            category: ocrResult.category,
            date: ocrResult.date ?? DateTime.now(),
          ),
        );

        if (result != null && mounted) {
          final receiptProvider = context.read<ReceiptProvider>();
          final subscriptionProvider = context.read<SubscriptionProvider>();
          result.imagePath = await ReceiptImageStore.persist(imagePath);
          await receiptProvider.addReceipt(result);
          await subscriptionProvider.incrementReceiptCount();
          HapticFeedback.mediumImpact();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Receipt saved! ✓'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to process image: $e')));
      }
    }
  }

  void _showUpgradePrompt() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Free Limit Reached'),
        content: const Text(
          'You\'ve used all 50 free receipts. Upgrade to Pro for unlimited scans.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const PaywallSheet(),
              );
            },
            child: const Text('View Pro plans'),
          ),
        ],
      ),
    );
  }

  TaxDeadline? _nextTaxDeadline() {
    final settings = Hive.box('settings');
    final now = DateTime.now();
    final deadlines =
        TaxReminderService.federal2026Deadlines
            .map((deadline) {
              final stored =
                  settings.get(
                        '${TaxReminderService.dateSettingsKeyPrefix}${deadline.id}',
                      )
                      as String?;
              return deadline.copyWith(
                date: stored == null ? null : DateTime.tryParse(stored),
              );
            })
            .where((deadline) => deadline.date.isAfter(now))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return deadlines.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>();
    final receipts = context.watch<ReceiptProvider>();
    final nextDeadline = _nextTaxDeadline();
    final remindersEnabled =
        Hive.box(
              'settings',
            ).get(TaxReminderService.enabledSettingsKey, defaultValue: false)
            as bool;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: AppTheme.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ReceiptSnap',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _PlanBadge(
                      label: sub.isPro ? 'PRO' : '${sub.remainingFree} FREE',
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Every receipt ready\nfor tax time.',
                  style: TextStyle(
                    fontSize: 34,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Keep every eligible tax dollar working for you.',
                  style: TextStyle(
                    color: AppTheme.blue,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Capture the record now. Review the tax treatment with source-backed guidance.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'THIS MONTH',
                        value: '${receipts.monthlyCount}',
                        detail: 'receipts',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'MONTH TOTAL',
                        value: NumberFormat.currency(
                          symbol: r'$',
                          decimalDigits: 0,
                        ).format(receipts.monthlyTotal),
                        detail: 'recorded',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        label: 'ALL RECORDS',
                        value: '${receipts.count}',
                        detail: 'saved',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _TaxGuideCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TaxGuideScreen()),
                  ),
                ),
                const SizedBox(height: 18),
                _ReminderCard(
                  deadline: nextDeadline,
                  enabled: remindersEnabled,
                  onTap: () =>
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TaxRemindersScreen(),
                        ),
                      ).then((_) {
                        if (mounted) setState(() {});
                      }),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _captureReceipt,
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: const Text('Scan a receipt'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose from Photos'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Category suggestions are for organization only. Verify tax treatment before filing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Reading receipt…',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaxGuideCard extends StatelessWidget {
  final VoidCallback onTap;

  const _TaxGuideCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.blue.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.blue.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      color: AppTheme.blue,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tax-time guide',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'IRS sources · reviewed July 2026',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'POSSIBLE EXPENSES TO REVIEW',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.55,
                ),
              ),
              const SizedBox(height: 9),
              const Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _GuideChip(label: 'Advertising'),
                  _GuideChip(label: 'Supplies'),
                  _GuideChip(label: 'Software'),
                  _GuideChip(label: 'Business travel'),
                  _GuideChip(label: 'Insurance'),
                  _GuideChip(label: 'Business-use phone'),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 7),
              const Text(
                'COMMONLY MISSED STEPS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.55,
                ),
              ),
              const SizedBox(height: 9),
              const _GuideStep(text: 'Add the business purpose'),
              const _GuideStep(text: 'Separate business and personal use'),
              const _GuideStep(text: 'Review uncategorized receipts monthly'),
              const _GuideStep(text: 'Keep receipts and proof of payment'),
              const SizedBox(height: 10),
              const Text(
                'Review prompts only — eligibility depends on your facts and current law.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideChip extends StatelessWidget {
  final String label;

  const _GuideChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.blue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String text;

  const _GuideStep({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_outline,
              size: 16,
              color: AppTheme.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final String label;

  const _PlanBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.blue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.blue,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;

  const _StatCard({
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          Text(
            detail,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final TaxDeadline? deadline;
  final bool enabled;
  final VoidCallback onTap;

  const _ReminderCard({
    required this.deadline,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dueDate = deadline?.date;
    final reminderDate = deadline == null
        ? null
        : TaxReminderService.reminderDateFor(deadline!);

    return Material(
      color: AppTheme.orange.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: AppTheme.orange,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Next tax reminder',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: enabled
                                ? AppTheme.green.withValues(alpha: 0.14)
                                : AppTheme.textTertiary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            enabled ? 'ON' : 'OFF',
                            style: TextStyle(
                              color: enabled
                                  ? AppTheme.green
                                  : AppTheme.textSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dueDate == null
                          ? 'Check IRS.gov for updated federal dates'
                          : '${DateFormat.MMMd().format(dueDate)} due · ${DateFormat.MMMd().format(reminderDate!)} reminder',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
