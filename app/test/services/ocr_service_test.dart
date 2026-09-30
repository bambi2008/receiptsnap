import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receiptsnap/services/ocr_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.receiptsnap.vision/ocr');

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('parses Apple Vision text into receipt fields', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'recognizeText');
          expect(call.arguments, {'imagePath': '/tmp/receipt.jpg'});
          return {
            'rawText':
                'STARBUCKS\nDate 07/19/2026\nSubtotal 10.00\nTOTAL 12.34',
            'confidence': 0.95,
          };
        });

    final result = await OcrService.processImage('/tmp/receipt.jpg');

    expect(result.vendorName, 'STARBUCKS');
    expect(result.amount, 12.34);
    expect(result.category, 'meals');
    expect(result.date, DateTime(2026, 7, 19));
  });

  test('uses safe defaults when Vision returns no text', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => {'rawText': ''});

    final result = await OcrService.processImage('/tmp/blank.jpg');

    expect(result.vendorName, 'Unknown Vendor');
    expect(result.amount, 0);
    expect(result.category, 'other');
    expect(result.date, isNull);
  });

  test('parses year-first and Chinese receipt dates', () {
    expect(
      OcrService.extractReceiptDate('日期：2026年09月22日 07:44'),
      DateTime(2026, 9, 22),
    );
    expect(
      OcrService.extractReceiptDate('Transaction date 2025-12-03'),
      DateTime(2025, 12, 3),
    );
    expect(OcrService.extractReceiptDate('2025.11.09'), DateTime(2025, 11, 9));
  });

  test('parses named-month receipt dates in either order', () {
    expect(
      OcrService.extractReceiptDate('DATE September 29, 2026'),
      DateTime(2026, 9, 29),
    );
    expect(
      OcrService.extractReceiptDate('Purchased 29 Sep 2026'),
      DateTime(2026, 9, 29),
    );
  });

  test('prefers a date-labelled line and rejects impossible dates', () {
    expect(
      OcrService.extractReceiptDate(
        'Member since 01/02/2020\nPurchase date 09/22/2026',
      ),
      DateTime(2026, 9, 22),
    );
    expect(OcrService.extractReceiptDate('DATE 13/40/2026'), isNull);
  });
}
