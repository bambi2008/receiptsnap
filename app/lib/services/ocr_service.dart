import 'package:flutter/services.dart';

/// Result from native Vision OCR.
class OcrResult {
  final String vendor;
  final double? total;
  final String? date;
  final String category;
  final double confidence;
  final String rawText;
  final List<OcrLineItem> lineItems;

  OcrResult({
    required this.vendor,
    this.total,
    this.date,
    required this.category,
    required this.confidence,
    required this.rawText,
    required this.lineItems,
  });

  factory OcrResult.fromMap(Map<String, dynamic> map) {
    return OcrResult(
      vendor: (map['vendor'] as String?) ?? 'Unknown Vendor',
      total: (map['total'] as num?)?.toDouble(),
      date: map['date'] as String?,
      category: (map['category'] as String?) ?? 'other',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      rawText: (map['rawText'] as String?) ?? '',
      lineItems: (map['lineItems'] as List<dynamic>?)
              ?.map((e) => OcrLineItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  String toString() =>
      'OcrResult(vendor: $vendor, total: $total, date: $date, category: $category, confidence: ${confidence.toStringAsFixed(2)})';
}

class OcrLineItem {
  final String description;
  final double? amount;

  OcrLineItem({required this.description, this.amount});

  factory OcrLineItem.fromMap(Map<String, dynamic> map) {
    return OcrLineItem(
      description: (map['description'] as String?) ?? '',
      amount: (map['amount'] as num?)?.toDouble(),
    );
  }
}

/// Service that wraps the native Vision OCR plugin via Method Channel.
class OcrService {
  static const _channel = MethodChannel('com.receiptsnap.vision/ocr');

  /// Run OCR on an image at [imagePath].
  /// Returns parsed [OcrResult] or throws on failure.
  static Future<OcrResult> recognizeText(String imagePath) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'recognizeText',
      {'imagePath': imagePath},
    );

    if (result == null || result.isEmpty) {
      throw OcrException('OCR returned no data');
    }

    return OcrResult.fromMap(Map<String, dynamic>.from(result));
  }

  /// Quick check if OCR is available on this platform.
  static Future<bool> get isAvailable async {
    // Vision OCR is iOS-only (15+). Android fallback would use ML Kit.
    try {
      await _channel.invokeMethod('recognizeText', {'imagePath': ''});
      return false; // will throw before reaching here on empty path
    } on MissingPluginException {
      return false;
    } catch (_) {
      // Error expected from empty path — means plugin IS available
      return true;
    }
  }
}

class OcrException implements Exception {
  final String message;
  OcrException(this.message);

  @override
  String toString() => 'OcrException: $message';
}
