import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:receiptsnap/app.dart';
import 'package:receiptsnap/models/receipt.dart';
import 'package:receiptsnap/providers/receipt_provider.dart';
import 'package:receiptsnap/providers/subscription_provider.dart';

final _receiptImage =
    '${Directory.systemTemp.path}/receiptsnap_visual_qa_receipt.png';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init('test_hive_visual_qa');
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ReceiptAdapter());
  });

  setUp(() async {
    final receipts = await Hive.openBox<Receipt>('receipts');
    final settings = await Hive.openBox('settings');
    await receipts.clear();
    await settings.clear();
    await settings.put('has_onboarded', true);
    await File(_receiptImage).writeAsBytes(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ),
    );
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    final image = File(_receiptImage);
    if (await image.exists()) await image.delete();
  });

  Future<ReceiptProvider> seedReceipts() async {
    final provider = ReceiptProvider()..loadReceipts();
    await provider.addReceipt(
      Receipt(
        vendorName: 'Transit Receipt',
        amount: 89,
        date: DateTime(2026, 9, 29),
        category: 'travel',
        imagePath: _receiptImage,
      ),
    );
    await provider.addReceipt(
      Receipt(
        vendorName: 'Studio Supplies',
        amount: 146,
        date: DateTime(2026, 9, 29),
        category: 'office_supplies',
      ),
    );
    return provider;
  }

  Future<void> pumpApp(WidgetTester tester, ReceiptProvider provider) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider(create: (_) => SubscriptionProvider()..init()),
        ],
        child: const ReceiptSnapApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Receipts'));
    await tester.pumpAndSettle();
  }

  testWidgets('visual QA detail keeps the full receipt visible', (
    tester,
  ) async {
    final provider = await tester.runAsync(seedReceipts);
    await pumpApp(tester, provider!);
    await tester.tap(find.text('Transit Receipt'));
    await tester.pumpAndSettle();
    await tester.pump();
    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('../docs/qa/detail_full_receipt.png'),
    );
  });

  testWidgets('visual QA batch export selection', (tester) async {
    final provider = await tester.runAsync(seedReceipts);
    await pumpApp(tester, provider!);
    await tester.tap(find.text('Export'));
    await tester.pump();
    await tester.tap(find.text('Select all'));
    await tester.pump();
    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('../docs/qa/batch_export.png'),
    );
  });
}
