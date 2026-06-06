import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';

class SubscriptionProvider extends ChangeNotifier {
  bool _isPro = false;
  int _receiptCount = 0;

  bool get isPro => _isPro;
  int get receiptCount => _receiptCount;
  int get remainingFree => isPro ? 999 : (AppConstants.freeReceiptLimit - _receiptCount).clamp(0, AppConstants.freeReceiptLimit);
  bool get hasReachedLimit => !_isPro && _receiptCount >= AppConstants.freeReceiptLimit;
  double get usageFraction => _isPro ? 1.0 : (_receiptCount / AppConstants.freeReceiptLimit).clamp(0.0, 1.0);

  void init() {
    final box = Hive.box('settings');
    _isPro = box.get(AppConstants.subscriptionKey, defaultValue: false);
    _receiptCount = box.get(AppConstants.receiptCountKey, defaultValue: 0);
    box.listenable().addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    final box = Hive.box('settings');
    _isPro = box.get(AppConstants.subscriptionKey, defaultValue: false);
    _receiptCount = box.get(AppConstants.receiptCountKey, defaultValue: 0);
    notifyListeners();
  }

  Future<void> upgradeToPro() async {
    await Hive.box('settings').put(AppConstants.subscriptionKey, true);
    _isPro = true;
    notifyListeners();
  }

  Future<void> restorePurchase() async {
    // TODO: Implement StoreKit 2 restore
  }
}
