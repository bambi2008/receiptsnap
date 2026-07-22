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
            'rawText': 'STARBUCKS\nDate 07/19/2026\nSubtotal 10.00\nTOTAL 12.34',
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
}
