import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/receipt.dart';

class ExportService {
  static String neutralizeSpreadsheetText(String value) {
    final normalized = value.replaceFirst('\ufeff', '');
    final startsFormula = RegExp(r'^[\x00-\x20]*[=+\-@]').hasMatch(normalized);
    return startsFormula ? "'$normalized" : normalized;
  }

  static Future<String?> exportCsv(List<Receipt> receipts) async {
    try {
      final rows = <List<String>>[
        Receipt.csvHeaders,
        ...receipts.map(
          (r) => [
            r.formattedDate,
            neutralizeSpreadsheetText(r.vendorName),
            neutralizeSpreadsheetText(r.category),
            r.amount.toStringAsFixed(2),
            neutralizeSpreadsheetText(r.note ?? ''),
          ],
        ),
      ];
      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/receiptsnap_export_${DateTime.now().microsecondsSinceEpoch}.csv',
      );
      await file.writeAsString(csv);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> exportPdf(List<Receipt> receipts) async {
    try {
      final grouped = <String, List<Receipt>>{};
      for (final r in receipts) {
        grouped.putIfAbsent(r.category, () => []).add(r);
      }

      double total = 0;
      final document = pw.Document();
      document.addPage(
        pw.MultiPage(
          build: (_) => [
            pw.Text(
              'ReceiptSnap Expense Report',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            ...grouped.entries.expand((entry) {
              final categoryTotal = entry.value.fold<double>(
                0,
                (sum, receipt) => sum + receipt.amount,
              );
              total += categoryTotal;
              return [
                pw.Text(
                  entry.key.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.TableHelper.fromTextArray(
                  headers: const ['Date', 'Vendor', 'Amount'],
                  data: entry.value
                      .map(
                        (receipt) => [
                          receipt.formattedDate,
                          receipt.vendorName,
                          receipt.formattedAmount,
                        ],
                      )
                      .toList(),
                ),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Subtotal: \$${categoryTotal.toStringAsFixed(2)}',
                  ),
                ),
                pw.SizedBox(height: 14),
              ];
            }),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/receiptsnap_report_${DateTime.now().microsecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await document.save(), flush: true);
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
