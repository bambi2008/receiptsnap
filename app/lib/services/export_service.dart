import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/receipt.dart';

class ExportService {
  static Future<String?> exportCsv(List<Receipt> receipts) async {
    try {
      final rows = <List<String>>[
        Receipt.csvHeaders,
        ...receipts.map((r) => [
          r.formattedDate,
          r.vendorName,
          r.category,
          r.amount.toStringAsFixed(2),
          r.note ?? '',
        ]),
      ];
      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/receiptsnap_export.csv');
      await file.writeAsString(csv);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> exportPdf(List<Receipt> receipts) async {
    try {
      // Group by category
      final grouped = <String, List<Receipt>>{};
      for (final r in receipts) {
        grouped.putIfAbsent(r.category, () => []).add(r);
      }

      // Build simple text-based report (PDF generation with full formatting in production)
      final buf = StringBuffer();
      buf.writeln('RECEIPTSNAP - Expense Report');
      buf.writeln('============================');
      buf.writeln();

      double total = 0;
      for (final entry in grouped.entries) {
        buf.writeln('Category: ${entry.key.toUpperCase()}');
        buf.writeln('---');
        double catTotal = 0;
        for (final r in entry.value) {
          buf.writeln('  ${r.formattedDate} | ${r.vendorName} | ${r.formattedAmount}');
          catTotal += r.amount;
        }
        buf.writeln('  Subtotal: \$${catTotal.toStringAsFixed(2)}');
        buf.writeln();
        total += catTotal;
      }
      buf.writeln('TOTAL: \$${total.toStringAsFixed(2)}');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/receiptsnap_report.txt');
      await file.writeAsString(buf.toString());
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
