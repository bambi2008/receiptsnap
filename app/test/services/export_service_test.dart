import 'package:flutter_test/flutter_test.dart';
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
}
