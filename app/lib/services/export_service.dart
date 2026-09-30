import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/receipt.dart';

class ExportService {
  static String neutralizeSpreadsheetText(String value) {
    final normalized = value.replaceFirst('\ufeff', '');
    final startsFormula = RegExp(r'^[\x00-\x20]*[=+\-@]').hasMatch(normalized);
    return startsFormula ? "'$normalized" : normalized;
  }

  static String buildCsv(List<Receipt> receipts) {
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
    return const ListToCsvConverter().convert(rows);
  }

  static Future<String?> exportCsv(List<Receipt> receipts) async {
    try {
      final csv = buildCsv(receipts);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/receiptsnap_${receipts.length}_receipts_${DateTime.now().microsecondsSinceEpoch}.csv',
      );
      await file.writeAsString(csv);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> exportPdf(List<Receipt> receipts) async {
    try {
      final bytes = await buildPdfBytes(receipts);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/receiptsnap_${receipts.length}_receipt_package_${DateTime.now().microsecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List> buildPdfBytes(List<Receipt> receipts) async {
    final sorted = [...receipts]..sort((a, b) => a.date.compareTo(b.date));
    final grouped = <String, List<Receipt>>{};
    for (final receipt in sorted) {
      grouped.putIfAbsent(receipt.category, () => []).add(receipt);
    }

    final document = pw.Document(
      title: 'ReceiptSnap receipt package',
      author: 'ReceiptSnap',
      subject: 'Expense records and supporting receipt images',
    );
    final total = sorted.fold<double>(0, (sum, item) => sum + item.amount);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => [
          pw.Text(
            'ReceiptSnap Expense Package',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '${sorted.length} supporting receipt${sorted.length == 1 ? '' : 's'}',
            style: const pw.TextStyle(color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 18),
          ...grouped.entries.expand((entry) {
            final categoryTotal = entry.value.fold<double>(
              0,
              (sum, receipt) => sum + receipt.amount,
            );
            return [
              pw.Text(
                entry.key.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
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
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                cellPadding: const pw.EdgeInsets.all(5),
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
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Recordkeeping aid only. Verify tax treatment and retain any additional proof of payment or business purpose that may be required.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    for (var index = 0; index < sorted.length; index++) {
      final receipt = sorted[index];
      pw.ImageProvider? image;
      final imagePath = receipt.imagePath;
      if (imagePath != null && imagePath.isNotEmpty) {
        try {
          final file = File(imagePath);
          if (await file.exists()) {
            image = pw.MemoryImage(await file.readAsBytes());
          }
        } catch (_) {
          image = null;
        }
      }

      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.all(32),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          receipt.vendorName,
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${receipt.formattedDate}  |  ${receipt.category}  |  ${receipt.formattedAmount}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        if (receipt.note?.trim().isNotEmpty == true) ...[
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Note: ${receipt.note!.trim()}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Text(
                    '${index + 1} / ${sorted.length}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Expanded(
                child: image == null
                    ? pw.Center(
                        child: pw.Text(
                          'Receipt image unavailable',
                          style: const pw.TextStyle(color: PdfColors.grey600),
                        ),
                      )
                    : pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
              ),
            ],
          ),
        ),
      );
    }

    return document.save();
  }
}
