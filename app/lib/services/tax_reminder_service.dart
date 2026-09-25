import 'package:flutter/services.dart';

class TaxDeadline {
  final String id;
  final String label;
  final DateTime date;

  const TaxDeadline({
    required this.id,
    required this.label,
    required this.date,
  });

  TaxDeadline copyWith({DateTime? date}) =>
      TaxDeadline(id: id, label: label, date: date ?? this.date);
}

class TaxReminderService {
  static const _channel = MethodChannel('com.receiptsnap.tax_reminders');
  static const reminderLeadTime = Duration(days: 7);
  static const enabledSettingsKey = 'tax_reminders_enabled';
  static const dateSettingsKeyPrefix = 'tax_reminder_date_';

  static final List<TaxDeadline> federal2026Deadlines = [
    TaxDeadline(
      id: 'federal_estimated_tax_2026_q1',
      label: '2026 estimated tax — payment 1',
      date: DateTime(2026, 4, 15, 9),
    ),
    TaxDeadline(
      id: 'federal_estimated_tax_2026_q2',
      label: '2026 estimated tax — payment 2',
      date: DateTime(2026, 6, 15, 9),
    ),
    TaxDeadline(
      id: 'federal_estimated_tax_2026_q3',
      label: '2026 estimated tax — payment 3',
      date: DateTime(2026, 9, 15, 9),
    ),
    TaxDeadline(
      id: 'federal_estimated_tax_2026_q4',
      label: '2026 estimated tax — payment 4',
      date: DateTime(2027, 1, 15, 9),
    ),
  ];

  static Future<bool> requestAuthorization() async {
    return await _channel.invokeMethod<bool>('requestAuthorization') ?? false;
  }

  static DateTime reminderDateFor(TaxDeadline deadline) =>
      deadline.date.subtract(reminderLeadTime);

  static Future<void> schedule(TaxDeadline deadline) async {
    final reminderDate = reminderDateFor(deadline);
    await _channel.invokeMethod<void>('scheduleReminder', {
      'id': deadline.id,
      'title': 'Estimated tax reminder',
      'body':
          '${deadline.label} may be due in 7 days. Check IRS Form 1040-ES and your tax professional.',
      'timestamp': reminderDate.millisecondsSinceEpoch,
    });
  }

  static Future<void> cancel(String id) async {
    await _channel.invokeMethod<void>('cancelReminder', {'id': id});
  }
}
