import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../config/constants.dart';

/// Product info from StoreKit 2.
class IapProduct {
  final String id;
  final String displayName;
  final String description;
  final double price;
  final String displayPrice;

  IapProduct({
    required this.id,
    required this.displayName,
    required this.description,
    required this.price,
    required this.displayPrice,
  });

  factory IapProduct.fromMap(Map<String, dynamic> map) {
    return IapProduct(
      id: map['id'] as String,
      displayName: (map['displayName'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      displayPrice: (map['displayPrice'] as String?) ?? '',
    );
  }
}

/// Manages subscription state via native StoreKit 2 plugin.
class SubscriptionProvider extends ChangeNotifier {
  static const _channel = MethodChannel('com.receiptsnap.storekit/iap');

  bool _isPro = false;
  int _receiptCount = 0;
  List<IapProduct> _products = [];
  bool _isLoading = true;
  String? _error;

  bool get isPro => _isPro;
  int get receiptCount => _receiptCount;
  List<IapProduct> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasProducts => _products.isNotEmpty;
  String? get error => _error;
  int get remainingFree =>
      isPro ? 999 : (AppConstants.freeReceiptLimit - _receiptCount).clamp(0, AppConstants.freeReceiptLimit);
  bool get hasReachedLimit => !_isPro && _receiptCount >= AppConstants.freeReceiptLimit;
  double get usageFraction => _isPro ? 1.0 : (_receiptCount / AppConstants.freeReceiptLimit).clamp(0.0, 1.0);

  /// Initialize: check entitlement + fetch products.
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _checkEntitlement();
      await _fetchProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Record a receipt scan. Called by camera screen after successful OCR+save.
  void incrementReceiptCount() {
    _receiptCount++;
    notifyListeners();
  }

  // --- Private helpers ---

  Future<void> _checkEntitlement() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('checkEntitlement');
      if (result != null) {
        _isPro = result['isPro'] == true;
      }
    } on MissingPluginException {
      // StoreKit unavailable (e.g., Android) — stay on local state
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getProducts');
      if (result != null) {
        _products = result
            .cast<Map<dynamic, dynamic>>()
            .map((m) => IapProduct.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }
    } on MissingPluginException {
      // No StoreKit — show local fallback pricing
      _products = [
        IapProduct(
          id: 'com.receiptsnap.pro.monthly',
          displayName: 'Pro Monthly',
          description: 'Unlimited scans, export, categories',
          price: 4.99,
          displayPrice: r'$4.99',
        ),
        IapProduct(
          id: 'com.receiptsnap.pro.annual',
          displayName: 'Pro Annual',
          description: 'All Pro features, best value',
          price: 39.99,
          displayPrice: r'$39.99',
        ),
      ];
    }
  }

  // --- Public API ---

  /// Purchase a product by ID.
  /// Returns a map with 'status' and optionally 'error'.
  Future<Map<String, dynamic>> purchase(String productId) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('purchase', productId);
      final status = result?['status'] as String? ?? 'unknown';

      if (status == 'purchased') {
        _isPro = true;
        notifyListeners();
      }

      return {'status': status};
    } on MissingPluginException {
      // Fallback for testing: simulate purchase
      _isPro = true;
      notifyListeners();
      return {'status': 'purchased'};
    } on PlatformException catch (e) {
      return {'status': 'error', 'error': e.message};
    }
  }

  /// Restore previous purchases.
  Future<void> restorePurchases() async {
    try {
      await _channel.invokeMethod('restorePurchases');
      await _checkEntitlement();
      notifyListeners();
    } on MissingPluginException {
      // no-op on unsupported platforms
    }
  }
}
