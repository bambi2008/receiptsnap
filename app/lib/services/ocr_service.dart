import 'package:flutter/services.dart';
import '../config/categories.dart';

class OcrResult {
  final String vendorName;
  final double amount;
  final String category;
  final DateTime? date;

  OcrResult({
    required this.vendorName,
    required this.amount,
    required this.category,
    this.date,
  });
}

class OcrService {
  static const _channel = MethodChannel('com.snapdeduct.app/ocr');

  static Future<OcrResult> processImage(String imagePath) async {
    String rawText;
    try {
      rawText = await _channel.invokeMethod<String>('recognizeText', {'path': imagePath}) ?? '';
    } catch (_) {
      return OcrResult(vendorName: 'Unknown Vendor', amount: 0.0, category: 'other', date: DateTime.now());
    }

    final lines = rawText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    String vendor = _extractVendor(lines);
    final amount = _extractAmount(lines, rawText);
    DateTime? date = _extractDate(rawText);
    final category = guessCategory(vendor);
    if (vendor.isEmpty || vendor.length < 2) vendor = 'Unknown Vendor';

    return OcrResult(vendorName: vendor, amount: amount > 0 ? amount : 0.0, category: category, date: date);
  }

  static String _extractVendor(List<String> lines) {
    final skipPrefixes = [
      'total', 'subtotal', 'tax', 'change', 'cash', 'credit',
      'debit', 'visa', 'mastercard', 'amex', 'thank', 'receipt',
      'store', 'phone', 'www', 'http', 'date', 'time', 'qty',
      'item', 'description', 'price',
    ];
    for (final line in lines) {
      final c = line.trim();
      if (c.isEmpty || c.length > 40) continue;
      final l = c.toLowerCase();
      if (!skipPrefixes.any((p) => l.startsWith(p)) && !RegExp(r'^\$?\d+\.?\d*$').hasMatch(c)) return c;
    }
    return 'Unknown Vendor';
  }

  static double _extractAmount(List<String> lines, String full) {
    final p = RegExp(r'\$?(\d+\.\d{2})');
    final m = p.allMatches(full).toList();
    if (m.isEmpty) return 0.0;
    for (final line in lines) {
      final lo = line.toLowerCase();
      if (lo.contains('total') || lo.contains('amount due') || lo.contains('balance')) {
        final mm = p.firstMatch(line);
        if (mm != null) return double.tryParse(mm.group(1)!) ?? 0.0;
      }
    }
    double max = 0.0;
    for (final mm in m) {
      final v = double.tryParse(mm.group(1)!) ?? 0.0;
      if (v > max) max = v;
    }
    return max;
  }

  static DateTime? _extractDate(String text) {
    final patterns = [
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'),
      RegExp(r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*\s+(\d{1,2}),?\s*(\d{4})'),
    ];
    for (final pat in patterns) {
      final m = pat.firstMatch(text);
      if (m == null) continue;
      try {
        if (m.group(1)!.contains(RegExp(r'[A-Za-z]'))) {
          final months = {'jan':1,'feb':2,'mar':3,'apr':4,'may':5,'jun':6,'jul':7,'aug':8,'sep':9,'oct':10,'nov':11,'dec':12};
          final mo = months[m.group(1)!.substring(0,3).toLowerCase()] ?? 1;
          return DateTime(int.tryParse(m.group(3)!)??DateTime.now().year, mo, int.tryParse(m.group(2)!)??1);
        } else {
          var y = int.tryParse(m.group(3)!) ?? DateTime.now().year;
          if (y < 100) y += 2000;
          return DateTime(y, int.tryParse(m.group(1)!)??1, int.tryParse(m.group(2)!)??1);
        }
      } catch (_) {}
    }
    return null;
  }
}
