import 'package:flutter_test/flutter_test.dart';
import 'package:receiptsnap/models/receipt.dart';
import 'package:receiptsnap/services/export_service.dart';

void main() {
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
      expect(csv.trim().split('\n'), hasLength(3));
    });

    test('PDF combines summary and selected receipt pages', () async {
      final bytes = await ExportService.buildPdfBytes(receipts);
      expect(bytes.length, greaterThan(1000));
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
