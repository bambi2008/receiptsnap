import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../config/categories.dart';
import '../config/constants.dart';
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
          r.date.year.toString(),
          r.id,
          _isoDate(r.date),
          neutralizeSpreadsheetText(r.vendorName),
          r.amount.toStringAsFixed(2),
          'USD',
          r.businessUsePercent.toStringAsFixed(1),
          r.businessAmount.toStringAsFixed(2),
          neutralizeSpreadsheetText(r.category),
          neutralizeSpreadsheetText(scheduleCReference(r.category)),
          neutralizeSpreadsheetText(r.note ?? ''),
          neutralizeSpreadsheetText(r.businessPurpose ?? ''),
          neutralizeSpreadsheetText(r.location ?? ''),
          neutralizeSpreadsheetText(r.paymentMethod ?? 'Not recorded'),
          neutralizeSpreadsheetText(r.reviewStatusLabel),
          neutralizeSpreadsheetText(_imageReference(r)),
          r.capturedAt.toUtc().toIso8601String(),
        ],
      ),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  static String _isoDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  static String _imageReference(Receipt receipt) {
    final path = receipt.imagePath;
    if (path == null || path.isEmpty) return 'No image';
    return '${receipt.id}_${p.basename(path)}';
  }

  static Future<String?> exportCsv(List<Receipt> receipts) async {
    try {
      final csv = buildCsv(receipts);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/freelance_tax_kit_${receipts.length}_receipts_${DateTime.now().microsecondsSinceEpoch}.csv',
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
        '${dir.path}/freelance_tax_kit_${receipts.length}_receipt_package_${DateTime.now().microsecondsSinceEpoch}.pdf',
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
      title: '${AppConstants.appName} receipt package',
      author: AppConstants.appName,
      subject: 'Expense records and supporting receipt images',
    );
    final grossTotal = sorted.fold<double>(0, (sum, item) => sum + item.amount);
    final businessTotal = sorted.fold<double>(
      0,
      (sum, item) => sum + item.businessAmount,
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => [
          pw.Text(
            '${AppConstants.appName} Self-Employed Tax Records Package',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '${sorted.length} supporting receipt${sorted.length == 1 ? '' : 's'}',
            style: const pw.TextStyle(color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 18),
          ...grouped.entries.expand((entry) {
            final categoryGross = entry.value.fold<double>(
              0,
              (sum, receipt) => sum + receipt.amount,
            );
            final categoryBusiness = entry.value.fold<double>(
              0,
              (sum, receipt) => sum + receipt.businessAmount,
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
                headers: const ['Date', 'Vendor', 'Gross', 'Business record'],
                data: entry.value
                    .map(
                      (receipt) => [
                        receipt.formattedDate,
                        receipt.vendorName,
                        receipt.formattedAmount,
                        '\$${receipt.businessAmount.toStringAsFixed(2)}',
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
                  'Gross: \$${categoryGross.toStringAsFixed(2)}  |  Business record amount: \$${categoryBusiness.toStringAsFixed(2)}',
                ),
              ),
              pw.SizedBox(height: 14),
            ];
          }),
          pw.Divider(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Gross total: \$${grossTotal.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Business record amount: \$${businessTotal.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Not a deduction determination',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'For an individual sole proprietor\'s recordkeeping and tax-preparer review. This package is not a tax return and does not determine deductibility. File Form 1040 and Schedule C as applicable, and retain any additional proof of payment, business purpose, travel, meal, gift, vehicle, or mixed-use details required for the expense.',
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
          final bytes = await _pdfReadyImageBytes(imagePath);
          if (bytes != null) image = pw.MemoryImage(bytes);
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
                        pw.SizedBox(height: 3),
                        pw.Text(
                          scheduleCReference(receipt.category),
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.Text(
                          'Receipt ID: ${receipt.id}',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          'Review: ${receipt.reviewStatusLabel}  |  Business use: ${receipt.businessUsePercent.toStringAsFixed(1)}%  |  Business amount: \$${receipt.businessAmount.toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                        if (receipt.businessPurpose?.trim().isNotEmpty == true)
                          pw.Text(
                            'Business purpose: ${receipt.businessPurpose!.trim()}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        if (receipt.location?.trim().isNotEmpty == true)
                          pw.Text(
                            'Location / destination: ${receipt.location!.trim()}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        if (receipt.paymentMethod?.trim().isNotEmpty == true)
                          pw.Text(
                            'Payment method: ${receipt.paymentMethod!.trim()}',
                            style: const pw.TextStyle(fontSize: 9),
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

  /// Decodes through Flutter's platform image codecs so iPhone HEIC photos are
  /// supported, then downsizes them before embedding. Keeping full camera
  /// resolution for every page makes a multi-receipt PDF appear to hang and can
  /// exhaust memory on older phones.
  static Future<Uint8List?> _pdfReadyImageBytes(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) return null;

    final source = await file.readAsBytes();
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? decoded;
    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(source);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final widthScale = 1400 / descriptor.width;
      final heightScale = 2400 / descriptor.height;
      final scale = [
        1.0,
        widthScale,
        heightScale,
      ].reduce((smallest, value) => value < smallest ? value : smallest);
      codec = await descriptor.instantiateCodec(
        targetWidth: (descriptor.width * scale).round(),
        targetHeight: (descriptor.height * scale).round(),
      );
      final frame = await codec.getNextFrame();
      decoded = frame.image;
      final data = await decoded.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    } finally {
      decoded?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }
}
