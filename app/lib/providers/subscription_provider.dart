import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  static const _channel = MethodChannel('com.snapdeduct.storekit/iap');

  SubscriptionProvider([this._settingsBox]);

  Box<dynamic>? _settingsBox;

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
  int get remainingFree => isPro
      ? 999
      : (AppConstants.freeReceiptLimit - _receiptCount).clamp(
          0,
          AppConstants.freeReceiptLimit,
        );
  bool get hasReachedLimit =>
      !_isPro && _receiptCount >= AppConstants.freeReceiptLimit;
  double get usageFraction => _isPro
      ? 1.0
      : (_receiptCount / AppConstants.freeReceiptLimit).clamp(0.0, 1.0);

  /// Initialize: check entitlement + fetch products.
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _loadReceiptCount();
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
  Future<void> incrementReceiptCount() async {
    _receiptCount++;
    await _settings().put(AppConstants.receiptCountKey, _receiptCount);
    notifyListeners();
  }

  // --- Private helpers ---

  Future<void> _checkEntitlement() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'checkEntitlement',
      );
      if (result != null) {
        _isPro = result['isPro'] == true;
      }
    } on MissingPluginException {
      _isPro = false;
      throw StateError('Purchases are unavailable on this device.');
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
      _products = [];
      throw StateError('App Store products are unavailable.');
    }
  }

  // --- Public API ---

  /// Purchase a product by ID.
  /// Returns a map with 'status' and optionally 'error'.
  Future<Map<String, dynamic>> purchase(String productId) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'purchase',
        productId,
      );
      final status = result?['status'] as String? ?? 'unknown';

      if (status == 'purchased') {
        _isPro = true;
        notifyListeners();
      }

      return {
        'status': status,
        if (result?['error'] != null) 'error': result?['error'],
      };
    } on MissingPluginException {
      return {
        'status': 'error',
        'error': 'Purchases are unavailable on this device.',
      };
    } on PlatformException catch (e) {
      return {'status': 'error', 'error': e.message};
    }
  }

  /// Restore previous purchases.
  Future<Map<String, dynamic>> restorePurchases() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'restorePurchases',
      );
      _isPro = result?['isPro'] == true;
      notifyListeners();
      return {'status': _isPro ? 'restored' : 'not_found'};
    } on MissingPluginException {
      return {
        'status': 'error',
        'error': 'Restore is unavailable on this device.',
      };
    } on PlatformException catch (e) {
      return {'status': 'error', 'error': e.message};
    }
  }

  Box<dynamic> _settings() => _settingsBox ??= Hive.box<dynamic>('settings');

  void _loadReceiptCount() {
    final value = _settings().get(
      AppConstants.receiptCountKey,
      defaultValue: 0,
    );
    _receiptCount = value is int && value >= 0 ? value : 0;
  }
}
