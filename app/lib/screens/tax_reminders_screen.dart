import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../services/tax_reminder_service.dart';

class TaxRemindersScreen extends StatefulWidget {
  const TaxRemindersScreen({super.key});

  @override
  State<TaxRemindersScreen> createState() => _TaxRemindersScreenState();
}

class _TaxRemindersScreenState extends State<TaxRemindersScreen> {
  static final _irsSource = Uri.parse(
    'https://www.irs.gov/payments/electronic-funds-withdrawal-and-credit-or-debit-card-payment-options-for-individuals',
  );
  static final _irsRecordsSource = Uri.parse(
    'https://www.irs.gov/publications/p583',
  );

  late List<TaxDeadline> _deadlines;
  bool _enabled = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final settings = Hive.box('settings');
    _enabled =
        settings.get(TaxReminderService.enabledSettingsKey, defaultValue: false)
            as bool;
    _deadlines = TaxReminderService.federal2026Deadlines.map((deadline) {
      final stored =
          settings.get(
                '${TaxReminderService.dateSettingsKeyPrefix}${deadline.id}',
              )
              as String?;
      final parsed = stored == null ? null : DateTime.tryParse(stored);
      return deadline.copyWith(date: parsed);
    }).toList();
  }

  Future<void> _setEnabled(bool value) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (value) {
        final authorized = await TaxReminderService.requestAuthorization();
        if (!authorized) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications are disabled in iOS Settings.'),
              ),
            );
          }
          return;
        }
        for (final deadline in _deadlines) {
          if (TaxReminderService.reminderDateFor(
            deadline,
          ).isAfter(DateTime.now())) {
            await TaxReminderService.schedule(deadline);
          }
        }
      } else {
        for (final deadline in _deadlines) {
          await TaxReminderService.cancel(deadline.id);
        }
      }
      await Hive.box(
        'settings',
      ).put(TaxReminderService.enabledSettingsKey, value);
      if (mounted) setState(() => _enabled = value);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editDeadline(int index) async {
    final current = _deadlines[index];
    final picked = await showDatePicker(
      context: context,
      initialDate: current.date,
      firstDate: DateTime(2026),
      lastDate: DateTime(2028, 12, 31),
      helpText: 'Choose your reminder date',
    );
    if (picked == null || !mounted) return;

    final updated = current.copyWith(
      date: DateTime(picked.year, picked.month, picked.day, 9),
    );
    await Hive.box('settings').put(
      '${TaxReminderService.dateSettingsKeyPrefix}${current.id}',
      updated.date.toIso8601String(),
    );
    if (_enabled) {
      await TaxReminderService.cancel(current.id);
      if (TaxReminderService.reminderDateFor(updated).isAfter(DateTime.now())) {
        await TaxReminderService.schedule(updated);
      }
    }
    if (mounted) setState(() => _deadlines[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Tax Reminders')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              value: _enabled,
              onChanged: _busy ? null : _setEnabled,
              secondary: const Icon(
                Icons.notifications_active_outlined,
                color: AppTheme.blue,
              ),
              title: const Text('Federal estimated-tax reminders'),
              subtitle: const Text(
                'Optional local notifications 7 days before. Due dates can be edited.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _NoticeCard(),
          const SizedBox(height: 20),
          const Text(
            '2026 GENERAL FEDERAL DATES',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_deadlines.length, (index) {
            final deadline = _deadlines[index];
            final passed = deadline.date.isBefore(DateTime.now());
            return Card(
              child: ListTile(
                leading: Icon(
                  passed ? Icons.check_circle_outline : Icons.event_outlined,
                  color: passed ? AppTheme.textTertiary : AppTheme.blue,
                ),
                title: Text(deadline.label),
                subtitle: Text(
                  '${DateFormat.yMMMMd().format(deadline.date)}${passed ? ' · passed' : ' · reminder 7 days before'}',
                ),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () => _editDeadline(index),
              ),
            );
          }),
          TextButton.icon(
            onPressed: () =>
                launchUrl(_irsSource, mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_new, size: 17),
            label: const Text('Verify dates on IRS.gov'),
          ),
          const SizedBox(height: 20),
          const Text(
            'IRS BUSINESS-EXPENSE FRAMEWORK',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          const _FrameworkCard(),
          TextButton.icon(
            onPressed: () => launchUrl(
              _irsRecordsSource,
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new, size: 17),
            label: const Text('Read IRS Publication 583'),
          ),
          const SizedBox(height: 20),
          const Text(
            'COMMONLY MISSED RECORDKEEPING STEPS',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 8),
          const _ActionItem(
            icon: Icons.edit_note_outlined,
            title: 'Add the business purpose',
            detail: 'Especially for meals, travel, gifts and mixed-use costs.',
          ),
          const _ActionItem(
            icon: Icons.call_split_outlined,
            title: 'Separate business and personal use',
            detail:
                'A receipt alone does not establish the business-use share.',
          ),
          const _ActionItem(
            icon: Icons.fact_check_outlined,
            title: 'Review uncategorized receipts monthly',
            detail: 'Confirm the vendor, amount, date and suggested category.',
          ),
          const _ActionItem(
            icon: Icons.folder_copy_outlined,
            title: 'Keep supporting records together',
            detail: 'Retain relevant receipts, invoices and proof of payment.',
          ),
        ],
      ),
    );
  }
}

class _FrameworkCard extends StatelessWidget {
  const _FrameworkCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'A category is a review prompt, not a deduction decision.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Common records include advertising, business travel, supplies, software, insurance, rent and business-use phone costs. Eligibility depends on your facts, business purpose, substantiation and current law.',
              style: TextStyle(height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.orange.withValues(alpha: 0.25)),
      ),
      child: const Text(
        'These are general calendar-year federal reminders, not a determination that you owe estimated tax. Exceptions, state deadlines and IRS relief may apply. Verify before acting.',
        style: TextStyle(fontSize: 13, height: 1.35),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.blue),
        title: Text(title),
        subtitle: Text(detail),
      ),
    );
  }
}
