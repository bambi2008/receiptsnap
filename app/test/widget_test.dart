import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:receiptsnap/app.dart';
import 'package:receiptsnap/config/theme.dart';
import 'package:receiptsnap/models/receipt.dart';
import 'package:receiptsnap/providers/receipt_provider.dart';
import 'package:receiptsnap/providers/subscription_provider.dart';

void main() {
  setUp(() async {
    Hive.init('test_hive_widget');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ReceiptAdapter());
    }
    final receipts = await Hive.openBox<Receipt>('receipts');
    final settings = await Hive.openBox('settings');
    await receipts.clear();
    await settings.clear();
    await settings.put('has_onboarded', true);
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
    expect(find.byKey(const Key('home_headline')), findsOneWidget);
    final headline = tester.widget<Text>(
      find.byKey(const Key('home_headline')),
    );
    final headlineSpan = headline.textSpan! as TextSpan;
    final receiptSpan = headlineSpan.children![1] as TextSpan;
    expect(receiptSpan.text, 'receipt');
    expect(receiptSpan.style!.color, AppTheme.red);
    expect(receiptSpan.style!.fontWeight, FontWeight.w900);
    final valueSubtitle = tester.widget<Text>(
      find.text('Keep every eligible tax dollar working for you.'),
    );
    expect(valueSubtitle.maxLines, 1);
    expect(valueSubtitle.softWrap, isFalse);
    expect(find.text('Freelancer Tax Blind Spots'), findsOneWidget);
    expect(
      find.text('Expenses worth a second look'.toUpperCase()),
      findsOneWidget,
    );
    expect(
      find.text('A receipt does not prove business purpose'),
      findsOneWidget,
    );

    await tester.tap(find.text('Freelancer Tax Blind Spots'));
    await tester.pumpAndSettle();
    expect(find.text('Freelancer Tax Blind Spots'), findsOneWidget);
    expect(find.text('Expenses to check'), findsOneWidget);
    expect(find.text('Mistakes to avoid'), findsOneWidget);
    expect(find.text('IRS-backed lessons, not generic tips'), findsOneWidget);
    expect(find.text('Your tax-season blind-spot check'), findsOneWidget);
    expect(find.textContaining('reviewed'), findsWidgets);
    expect(find.text('Federal estimated-tax reminders'), findsNothing);

    await tester.drag(find.byType(ListView).last, const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('Advertising and marketing'), findsOneWidget);
    final advertisingCard = find.ancestor(
      of: find.text('Advertising and marketing'),
      matching: find.byType(ExpansionTile),
    );
    final advertisingCheckbox = find.descendant(
      of: advertisingCard,
      matching: find.byType(Checkbox),
    );
    expect(advertisingCheckbox, findsOneWidget);
    expect(tester.widget<Checkbox>(advertisingCheckbox).value, isFalse);
    expect(tester.widget<Checkbox>(advertisingCheckbox).onChanged, isNotNull);
  });

  testWidgets('app keeps receipt capture visible in bottom navigation', (
    tester,
  ) async {
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
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Receipts'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();
    expect(find.text('Add a receipt'), findsOneWidget);
    expect(find.text('Scan a receipt'), findsOneWidget);
    expect(find.text('Choose from Photos'), findsOneWidget);
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

  testWidgets('receipt shows matched expense and pitfall prompts', (
    tester,
  ) async {
    final receiptProvider = ReceiptProvider();
    receiptProvider.loadReceipts();
    await tester.runAsync(
      () => receiptProvider.addReceipt(
        Receipt(
          vendorName: 'Client Dinner',
          amount: 84.20,
          date: DateTime(2026, 7, 23),
          category: 'meals',
        ),
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: receiptProvider),
          ChangeNotifierProvider(create: (_) => SubscriptionProvider()..init()),
        ],
        child: const ReceiptSnapApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Receipts'));
    await tester.pumpAndSettle();
    expect(find.text('Review: Possible business meal'), findsOneWidget);
    expect(find.text('Often limited; entertainment differs'), findsOneWidget);

    await tester.tap(find.text('Client Dinner'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pump();
    expect(find.text('Tax blind spots for this receipt'), findsOneWidget);
    expect(find.text('POSSIBLE EXPENSE RULE TO REVIEW'), findsOneWidget);
    expect(find.text('FREELANCER TRAP TO AVOID'), findsOneWidget);
    expect(find.textContaining('Do now:'), findsOneWidget);
  });
}
