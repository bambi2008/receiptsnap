import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:receiptsnap/models/receipt.dart';
import 'package:receiptsnap/services/export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('spreadsheet export safety', () {
    test('neutralizes formula-significant prefixes', () {
      for (final value in [
        '=1+1',
        '+cmd',
        '-10+20',
        '@SUM(A1:A2)',
        '  =HYPERLINK("x")',
      ]) {
        expect(ExportService.neutralizeSpreadsheetText(value), startsWith("'"));
      }
    });

    test('preserves ordinary receipt text', () {
      expect(
        ExportService.neutralizeSpreadsheetText('Coffee Shop'),
        'Coffee Shop',
      );
    });
  });

  group('batch exports', () {
    final receipts = [
      Receipt(
        vendorName: 'Studio Supply',
        amount: 12.50,
        date: DateTime(2026, 1, 2),
        category: 'supplies',
      ),
      Receipt(
        vendorName: 'Client Travel',
        amount: 40,
        date: DateTime(2026, 1, 3),
        category: 'travel',
      ),
    ];

    test('CSV contains every selected receipt', () {
      final csv = ExportService.buildCsv(receipts);
      expect(csv, contains('Studio Supply'));
      expect(csv, contains('Client Travel'));
      expect(csv, contains('Suggested Schedule C Reference'));
      expect(csv, contains('Business Purpose'));
      expect(csv, contains('Receipt Image Reference'));
      expect(csv, contains('USD'));
      expect(csv.trim().split('\n'), hasLength(3));
    });

    test('CSV carries sole-proprietor review and substantiation fields', () {
      final csv = ExportService.buildCsv([
        Receipt(
          id: 'receipt-123',
          vendorName: 'Client Cafe',
          amount: 50,
          date: DateTime(2026, 4, 15),
          category: 'meals',
          note: 'Lunch for two',
          businessPurpose: 'Discuss client project',
          location: 'Austin, TX',
          paymentMethod: 'Personal card',
          businessUsePercent: 50,
          reviewStatus: receiptReviewConfirmedBusiness,
          capturedAt: DateTime.utc(2026, 4, 15, 18),
        ),
      ]);

      expect(csv, contains('2026-04-15'));
      expect(csv, contains('receipt-123'));
      expect(csv, contains('Discuss client project'));
      expect(csv, contains('Austin, TX'));
      expect(csv, contains('25.00'));
      expect(csv, contains('Schedule C, line 24b'));
      expect(csv, contains('Confirmed business record'));
    });

    test('PDF combines summary and selected receipt pages', () async {
      final bytes = await ExportService.buildPdfBytes(receipts);
      expect(bytes.length, greaterThan(1000));
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('PDF decodes and embeds a saved receipt image', () async {
      final image = File(
        '${Directory.systemTemp.path}/receiptsnap_export_test.png',
      );
      await image.writeAsBytes(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ),
      );
      addTearDown(() async {
        if (await image.exists()) await image.delete();
      });

      final bytes = await ExportService.buildPdfBytes([
        Receipt(
          vendorName: 'Image Receipt',
          amount: 25,
          date: DateTime(2026, 9, 22),
          category: 'other',
          imagePath: image.path,
        ),
      ]);

      expect(bytes.length, greaterThan(1000));
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
