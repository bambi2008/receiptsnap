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
  static const _channel = MethodChannel('com.receiptsnap.vision/ocr');

  static Future<OcrResult> processImage(String imagePath) async {
    final response = await _channel.invokeMapMethod<String, dynamic>(
      'recognizeText',
      {'imagePath': imagePath},
    );
    final fullText = response?['rawText'] as String? ?? '';
    final lines = fullText
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    // Extract vendor name: usually the first meaningful line
    String vendor = _extractVendor(lines);

    // Extract amount: look for dollar amounts
    final amount = _extractAmount(lines, fullText);

    // Extract date: look for date patterns
    final date = extractReceiptDate(fullText);

    // Guess category from vendor name
    final category = guessCategory(vendor);

    // If vendor looks like junk (OCR noise), use fallback
    if (vendor.isEmpty || vendor.length < 2) {
      vendor = 'Unknown Vendor';
    }

    // If no amount found, use 0
    final safeAmount = amount > 0 ? amount : 0.0;

    return OcrResult(
      vendorName: vendor,
      amount: safeAmount,
      category: category,
      date: date,
    );
  }

  static String _extractVendor(List<String> lines) {
    // Skip common non-vendor lines
    final skipPrefixes = [
      'total',
      'subtotal',
      'tax',
      'change',
      'cash',
      'credit',
      'debit',
      'visa',
      'mastercard',
      'amex',
      'thank',
      'receipt',
      'store',
      'phone',
      'www',
      'http',
      'date',
      'time',
      'qty',
      'item',
      'description',
      'price',
    ];

    for (final line in lines) {
      final cleaned = line.trim();
      if (cleaned.isEmpty || cleaned.length > 40) continue;

      final lower = cleaned.toLowerCase();
      final isSkip = skipPrefixes.any((p) => lower.startsWith(p));
      if (!isSkip && !RegExp(r'^\$?\d+\.?\d*$').hasMatch(cleaned)) {
        // Found a likely vendor name
        return cleaned;
      }
    }

    return 'Unknown Vendor';
  }

  static double _extractAmount(List<String> lines, String fullText) {
    // Find lines with $ amounts, prioritize "total" lines
    final amountPattern = RegExp(r'\$?(\d+\.\d{2})');
    final matches = amountPattern.allMatches(fullText).toList();

    if (matches.isEmpty) return 0.0;

    // Look for total-related amounts first
    final totalLabelPattern = RegExp(
      r'\b(total|amount due|balance)\b',
      caseSensitive: false,
    );
    for (final line in lines) {
      if (totalLabelPattern.hasMatch(line)) {
        final match = amountPattern.firstMatch(line);
        if (match != null) {
          return double.tryParse(match.group(1)!) ?? 0.0;
        }
      }
    }

    // Otherwise return the largest amount (likely the total)
    double largest = 0.0;
    for (final match in matches) {
      final val = double.tryParse(match.group(1)!) ?? 0.0;
      if (val > largest) largest = val;
    }
    return largest;
  }

  static const _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  /// Extracts the transaction date printed on a receipt. Date-labelled lines
  /// are checked first so unrelated identifiers or loyalty dates do not win.
  static DateTime? extractReceiptDate(String text) {
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final dateLabel = RegExp(
      r'\b(date|purchased|purchase|transaction|invoice)\b|日期|开票',
      caseSensitive: false,
    );
    final prioritized = [
      ...lines.where(dateLabel.hasMatch),
      ...lines.where((line) => !dateLabel.hasMatch(line)),
    ];

    for (final line in prioritized) {
      final parsed = _parseDateLine(line);
      if (parsed != null) return parsed;
    }
    return null;
  }

  static DateTime? _parseDateLine(String line) {
    Match? match;

    // YYYY-MM-DD, YYYY/MM/DD, YYYY.MM.DD, and YYYY年MM月DD日.
    match = RegExp(
      r'\b(19\d{2}|20\d{2})\s*(?:[-/.]|年)\s*(\d{1,2})\s*(?:[-/.]|月)\s*(\d{1,2})(?:日)?\b',
    ).firstMatch(line);
    if (match != null) {
      return _validDate(match.group(1), match.group(2), match.group(3));
    }

    // US numeric receipt dates: MM/DD/YYYY and MM-DD-YY.
    match = RegExp(
      r'\b(\d{1,2})[/-](\d{1,2})[/-](\d{2}|\d{4})\b',
    ).firstMatch(line);
    if (match != null) {
      var year = int.tryParse(match.group(3)!);
      if (year != null && year < 100) year += year >= 70 ? 1900 : 2000;
      return _validDate(year?.toString(), match.group(1), match.group(2));
    }

    // Sep 29, 2026 / September 29 2026.
    match = RegExp(
      r'\b(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:t(?:ember)?)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\s+(\d{1,2})(?:st|nd|rd|th)?,?\s+(\d{4})\b',
      caseSensitive: false,
    ).firstMatch(line);
    if (match != null) {
      final month = _months[match.group(1)!.substring(0, 3).toLowerCase()];
      return _validDate(match.group(3), month?.toString(), match.group(2));
    }

    // 29 Sep 2026 / 29 September, 2026.
    match = RegExp(
      r'\b(\d{1,2})(?:st|nd|rd|th)?\s+(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:t(?:ember)?)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?),?\s+(\d{4})\b',
      caseSensitive: false,
    ).firstMatch(line);
    if (match != null) {
      final month = _months[match.group(2)!.substring(0, 3).toLowerCase()];
      return _validDate(match.group(3), month?.toString(), match.group(1));
    }

    return null;
  }

  static DateTime? _validDate(String? year, String? month, String? day) {
    final y = int.tryParse(year ?? '');
    final m = int.tryParse(month ?? '');
    final d = int.tryParse(day ?? '');
    if (y == null || m == null || d == null || y < 1990 || y > 2100) {
      return null;
    }
    final candidate = DateTime(y, m, d);
    if (candidate.year != y || candidate.month != m || candidate.day != d) {
      return null;
    }
    return candidate;
  }
}
