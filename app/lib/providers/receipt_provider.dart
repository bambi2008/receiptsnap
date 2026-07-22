import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/receipt.dart';
import '../services/receipt_image_store.dart';

class ReceiptProvider extends ChangeNotifier {
  late Box<Receipt> _box;
  List<Receipt> _receipts = [];

  List<Receipt> get receipts => _receipts;
  List<Receipt> get receiptsReversed => _receipts.reversed.toList();

  int get count => _receipts.length;
  double get monthlyTotal {
    final now = DateTime.now();
    return _receipts
        .where((r) => r.date.month == now.month && r.date.year == now.year)
        .fold(0.0, (sum, r) => sum + r.amount);
  }

  int get monthlyCount {
    final now = DateTime.now();
    return _receipts
        .where((r) => r.date.month == now.month && r.date.year == now.year)
        .length;
  }

  Map<String, List<Receipt>> get groupedByMonth {
    final map = <String, List<Receipt>>{};
    for (final r in receiptsReversed) {
      map.putIfAbsent(r.monthYearKey, () => []).add(r);
    }
    return map;
  }

  void loadReceipts() {
    _box = Hive.box<Receipt>('receipts');
    _receipts = _box.values.toList();
    notifyListeners();
  }

  Future<void> addReceipt(Receipt receipt) async {
    _validate(receipt);
    await _box.put(receipt.id, receipt);
    _receipts.add(receipt);
    notifyListeners();
  }

  Future<void> updateReceipt(Receipt receipt) async {
    _validate(receipt);
    await _box.put(receipt.id, receipt);
    final idx = _receipts.indexWhere((r) => r.id == receipt.id);
    if (idx != -1) _receipts[idx] = receipt;
    notifyListeners();
  }

  Future<void> deleteReceipt(String id) async {
    final receipt = _receipts.where((item) => item.id == id).firstOrNull;
    await _box.delete(id);
    _receipts.removeWhere((r) => r.id == id);
    await ReceiptImageStore.deleteIfManaged(receipt?.imagePath);
    notifyListeners();
  }

  Future<void> clearAll() async {
    final imagePaths = _receipts.map((receipt) => receipt.imagePath).toList();
    await _box.clear();
    _receipts.clear();
    for (final imagePath in imagePaths) {
      await ReceiptImageStore.deleteIfManaged(imagePath);
    }
    notifyListeners();
  }

  List<Receipt> search(String query) {
    if (query.isEmpty) return receiptsReversed;
    final q = query.toLowerCase();
    return receiptsReversed
        .where((r) => r.vendorName.toLowerCase().contains(q))
        .toList();
  }

  void _validate(Receipt receipt) {
    if (receipt.vendorName.trim().isEmpty) {
      throw ArgumentError.value(
        receipt.vendorName,
        'vendorName',
        'Vendor is required.',
      );
    }
    if (!receipt.amount.isFinite ||
        receipt.amount < 0 ||
        receipt.amount > 10000000) {
      throw ArgumentError.value(
        receipt.amount,
        'amount',
        'Amount must be from 0 to 10,000,000.',
      );
    }
  }
}
