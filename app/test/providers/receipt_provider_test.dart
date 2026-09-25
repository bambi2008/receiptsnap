import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:receiptsnap/models/receipt.dart';
import 'package:receiptsnap/providers/receipt_provider.dart';

void main() {
  late ReceiptProvider provider;

  setUp(() async {
    Hive.init('test_hive_provider');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ReceiptAdapter());
    }
    await Hive.openBox<Receipt>('receipts');
    await Hive.openBox('settings');
    provider = ReceiptProvider();
    provider.loadReceipts();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  group('ReceiptProvider', () {
    test('starts with empty receipts', () {
      expect(provider.count, 0);
      expect(provider.receipts, isEmpty);
    });

    test('addReceipt increments count', () async {
      await provider.addReceipt(
        Receipt(
          vendorName: 'Starbucks',
          amount: 12.50,
          date: DateTime.now(),
          category: 'meals',
        ),
      );
      expect(provider.count, 1);
    });

    test('addReceipt adds to list', () async {
      final receipt = Receipt(
        vendorName: 'Amazon',
        amount: 45.99,
        date: DateTime.now(),
        category: 'office_supplies',
      );
      await provider.addReceipt(receipt);
      expect(provider.receipts.first.vendorName, 'Amazon');
      expect(provider.receipts.first.amount, 45.99);
    });

    test('multiple addReceipts accumulate', () async {
      for (var i = 0; i < 5; i++) {
        await provider.addReceipt(
          Receipt(
            vendorName: 'Vendor $i',
            amount: (i + 1) * 10.0,
            date: DateTime.now(),
            category: 'other',
          ),
        );
      }
      expect(provider.count, 5);
    });

    test('updateReceipt modifies existing receipt', () async {
      final receipt = Receipt(
        vendorName: 'Original',
        amount: 10,
        date: DateTime.now(),
        category: 'other',
      );
      await provider.addReceipt(receipt);

      receipt.vendorName = 'Updated';
      receipt.amount = 20;
      await provider.updateReceipt(receipt);

      final updated = provider.receipts.first;
      expect(updated.vendorName, 'Updated');
      expect(updated.amount, 20);
    });

    test('deleteReceipt removes from list', () async {
      final receipt = Receipt(
        vendorName: 'To Delete',
        amount: 5,
        date: DateTime.now(),
        category: 'other',
      );
      await provider.addReceipt(receipt);
      expect(provider.count, 1);

      await provider.deleteReceipt(receipt.id);
      expect(provider.count, 0);
    });

    test('deleteReceipt only removes the correct one', () async {
      final a = Receipt(
        vendorName: 'A',
        amount: 1,
        date: DateTime.now(),
        category: 'other',
      );
      final b = Receipt(
        vendorName: 'B',
        amount: 2,
        date: DateTime.now(),
        category: 'other',
      );
      await provider.addReceipt(a);
      await provider.addReceipt(b);
      expect(provider.count, 2);

      await provider.deleteReceipt(a.id);
      expect(provider.count, 1);
      expect(provider.receipts.first.vendorName, 'B');
    });

    test('monthlyTotal sums current month receipts', () async {
      final now = DateTime.now();
      await provider.addReceipt(
        Receipt(
          vendorName: 'Current',
          amount: 100,
          date: now,
          category: 'other',
        ),
      );
      expect(provider.monthlyTotal, 100.0);
    });

    test('monthlyCount counts only current month', () async {
      final now = DateTime.now();
      await provider.addReceipt(
        Receipt(vendorName: 'C1', amount: 10, date: now, category: 'other'),
      );
      await provider.addReceipt(
        Receipt(vendorName: 'C2', amount: 20, date: now, category: 'other'),
      );
      expect(provider.monthlyCount, 2);
    });

    group('search', () {
      test('empty query returns all receipts reversed', () async {
        await provider.addReceipt(
          Receipt(
            vendorName: 'First',
            amount: 1,
            date: DateTime.now(),
            category: 'other',
          ),
        );
        await provider.addReceipt(
          Receipt(
            vendorName: 'Second',
            amount: 2,
            date: DateTime.now(),
            category: 'other',
          ),
        );

        final results = provider.search('');
        expect(results.length, 2);
        expect(results.first.vendorName, 'Second');
      });

      test('search filters by vendor name', () async {
        await provider.addReceipt(
          Receipt(
            vendorName: 'Starbucks',
            amount: 5,
            date: DateTime.now(),
            category: 'meals',
          ),
        );
        await provider.addReceipt(
          Receipt(
            vendorName: 'Amazon',
            amount: 50,
            date: DateTime.now(),
            category: 'office_supplies',
          ),
        );

        final results = provider.search('star');
        expect(results.length, 1);
        expect(results.first.vendorName, 'Starbucks');
      });

      test('search is case insensitive', () async {
        await provider.addReceipt(
          Receipt(
            vendorName: 'STARBUCKS',
            amount: 5,
            date: DateTime.now(),
            category: 'meals',
          ),
        );

        expect(provider.search('starbucks').length, 1);
        expect(provider.search('STAR').length, 1);
        expect(provider.search('star').length, 1);
      });

      test('search no match returns empty', () async {
        await provider.addReceipt(
          Receipt(
            vendorName: 'Starbucks',
            amount: 5,
            date: DateTime.now(),
            category: 'meals',
          ),
        );
        expect(provider.search('nonexistent'), isEmpty);
      });
    });

    group('groupedByMonth', () {
      test('groups receipts by month', () async {
        await provider.addReceipt(
          Receipt(
            vendorName: 'Jun Receipt',
            amount: 10,
            date: DateTime(2026, 6, 1),
            category: 'other',
          ),
        );
        await provider.addReceipt(
          Receipt(
            vendorName: 'May Receipt',
            amount: 20,
            date: DateTime(2026, 5, 15),
            category: 'other',
          ),
        );

        final grouped = provider.groupedByMonth;
        expect(grouped.length, 2);
        expect(grouped.containsKey('JUNE 2026'), true);
        expect(grouped.containsKey('MAY 2026'), true);
      });
    });
  });
}
