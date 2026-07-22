import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:receiptsnap/app.dart';
import 'package:receiptsnap/models/receipt.dart';
import 'package:receiptsnap/providers/receipt_provider.dart';
import 'package:receiptsnap/providers/subscription_provider.dart';

void main() {
  setUp(() async {
    Hive.init('test_hive_widget');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ReceiptAdapter());
    }
    await Hive.openBox<Receipt>('receipts');
    await Hive.openBox('settings');
    Hive.box('settings').put('has_onboarded', true);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  testWidgets('app builds and shows home dashboard', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ReceiptProvider()..loadReceipts(),
          ),
          ChangeNotifierProvider(create: (_) => SubscriptionProvider()..init()),
        ],
        child: const ReceiptSnapApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Every receipt ready\nfor tax time.'), findsOneWidget);
    expect(find.text('Tax-time guide'), findsOneWidget);
    expect(
      find.text('Possible expenses to review'.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text('Add the business purpose'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Scan a receipt'), 400);
    expect(find.text('Next tax reminder'), findsOneWidget);
    expect(find.text('Scan a receipt'), findsOneWidget);
  });

  testWidgets('app has 3 navigation tabs', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ReceiptProvider()..loadReceipts(),
          ),
          ChangeNotifierProvider(create: (_) => SubscriptionProvider()..init()),
        ],
        child: const ReceiptSnapApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Receipts'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

  testWidgets('tapping tabs switches content', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ReceiptProvider()..loadReceipts(),
          ),
          ChangeNotifierProvider(create: (_) => SubscriptionProvider()..init()),
        ],
        child: const ReceiptSnapApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Receipts'));
    await tester.pumpAndSettle();
    expect(find.text('No receipts yet'), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('FREE'), findsWidgets);
    expect(find.text('Tax Reminders'), findsOneWidget);

    await tester.tap(find.text('Tax Reminders'));
    await tester.pumpAndSettle();
    expect(find.text('Federal estimated-tax reminders'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('IRS BUSINESS-EXPENSE FRAMEWORK'),
      300,
    );
    expect(find.text('IRS BUSINESS-EXPENSE FRAMEWORK'), findsOneWidget);
  });
}
