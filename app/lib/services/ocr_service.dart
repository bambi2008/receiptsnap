import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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
  static final TextRecognizer _recognizer = TextRecognizer();

  static Future<OcrResult> processImage(String imagePath) async {
    final file = File(imagePath);
    final inputImage = InputImage.fromFile(file);
    final recognizedText = await _recognizer.processImage(inputImage);

    final fullText = recognizedText.text;
    final lines = fullText.split('\n').where((l) => l.trim().isNotEmpty).toList();

    // Extract vendor name: usually the first meaningful line
    String vendor = _extractVendor(lines);

    // Extract amount: look for dollar amounts
    final amount = _extractAmount(lines, fullText);

    // Extract date: look for date patterns
    DateTime? date = _extractDate(fullText);

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
      'total', 'subtotal', 'tax', 'change', 'cash', 'credit',
      'debit', 'visa', 'mastercard', 'amex', 'thank', 'receipt',
      'store', 'phone', 'www', 'http', 'date', 'time', 'qty',
      'item', 'description', 'price',
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
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains('total') || lower.contains('amount due') || lower.contains('balance')) {
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

  static DateTime? _extractDate(String text) {
    // Match common date formats: MM/DD/YYYY, MM-DD-YYYY, Mon DD, YYYY
    final patterns = [
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'),
      RegExp(r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*\s+(\d{1,2}),?\s*(\d{4})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          if (match.groupCount >= 3 && match.group(1)!.contains(RegExp(r'[A-Za-z]'))) {
            // Named month format
            final months = {
              'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
              'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
            };
            final m = months[match.group(1)!.substring(0, 3).toLowerCase()] ?? 1;
            final d = int.tryParse(match.group(2)!) ?? 1;
            final y = int.tryParse(match.group(3)!) ?? DateTime.now().year;
            return DateTime(y, m, d);
          } else {
            // Numeric format
            final m = int.tryParse(match.group(1)!) ?? 1;
            final d = int.tryParse(match.group(2)!) ?? 1;
            var y = int.tryParse(match.group(3)!) ?? DateTime.now().year;
            if (y < 100) y += 2000;
            return DateTime(y, m, d);
          }
        } catch (_) {
          // Parsing failed, continue
        }
      }
    }
    return null;
  }

  static void dispose() {
    _recognizer.close();
  }
}
