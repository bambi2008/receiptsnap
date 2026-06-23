import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:receiptsnap/app.dart';
import 'package:receiptsnap/models/receipt.dart';
import 'package:receiptsnap/providers/receipt_provider.dart';
import 'package:receiptsnap/providers/subscription_provider.dart';
import 'package:receiptsnap/providers/insights_provider.dart';

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

  Widget buildApp() => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ReceiptProvider()..loadReceipts()),
          ChangeNotifierProvider(create: (_) => SubscriptionProvider()..init()),
          ChangeNotifierProvider(create: (_) => InsightsProvider()..init()),
        ],
        child: const SnapDeductApp(),
      );

  testWidgets('app builds and shows home tab', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('app has 4 navigation tabs', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Receipts'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

  testWidgets('tapping tabs switches content', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();
    expect(find.text('Position receipt in frame'), findsOneWidget);

    await tester.tap(find.text('Receipts'));
    await tester.pumpAndSettle();
    expect(find.text('THIS MONTH'), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('FREE'), findsWidgets);
  });
}
