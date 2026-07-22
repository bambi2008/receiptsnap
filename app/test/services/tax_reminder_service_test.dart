import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receiptsnap/services/tax_reminder_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.receiptsnap.tax_reminders');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'requestAuthorization') return true;
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('uses the published general 2026 estimated-tax dates', () {
    expect(TaxReminderService.federal2026Deadlines.map((item) => item.date), [
      DateTime(2026, 4, 15, 9),
      DateTime(2026, 6, 15, 9),
      DateTime(2026, 9, 15, 9),
      DateTime(2027, 1, 15, 9),
    ]);
  });

  test('requests permission only through an explicit call', () async {
    expect(await TaxReminderService.requestAuthorization(), isTrue);
    expect(calls.single.method, 'requestAuthorization');
  });

  test('schedules a local reminder seven days before the due date', () async {
    final deadline = TaxReminderService.federal2026Deadlines.last;

    await TaxReminderService.schedule(deadline);

    expect(calls.single.method, 'scheduleReminder');
    final arguments = calls.single.arguments as Map<Object?, Object?>;
    expect(arguments['id'], deadline.id);
    expect(
      arguments['timestamp'],
      DateTime(2027, 1, 8, 9).millisecondsSinceEpoch,
    );
    expect(arguments['body'], contains('may be due in 7 days'));
  });

  test('cancels by stable reminder identifier', () async {
    await TaxReminderService.cancel('federal_estimated_tax_2026_q3');

    expect(calls.single.method, 'cancelReminder');
    expect(calls.single.arguments, {'id': 'federal_estimated_tax_2026_q3'});
  });
}
