import 'package:flutter_test/flutter_test.dart';
import 'package:receiptsnap/models/receipt.dart';

void main() {
  group('Receipt model', () {
    test('creates with auto-generated id', () {
      final receipt = Receipt(
        vendorName: 'Starbucks',
        amount: 12.50,
        date: DateTime(2026, 6, 5),
        category: 'meals',
      );
      expect(receipt.id, isNotEmpty);
      expect(receipt.id.length, greaterThan(10));
    });

    test('accepts custom id', () {
      final receipt = Receipt(
        id: 'custom-123',
        vendorName: 'Amazon',
        amount: 45.99,
        date: DateTime(2026, 5, 15),
        category: 'office_supplies',
      );
      expect(receipt.id, 'custom-123');
    });

    test('each receipt gets unique id', () {
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
      expect(a.id, isNot(b.id));
    });

    test('formattedAmount adds dollar sign and 2 decimals', () {
      final receipt = Receipt(
        vendorName: 'Test',
        amount: 12.5,
        date: DateTime.now(),
        category: 'other',
      );
      expect(receipt.formattedAmount, '\$12.50');
    });

    test('formattedAmount handles round numbers', () {
      final receipt = Receipt(
        vendorName: 'Test',
        amount: 100,
        date: DateTime.now(),
        category: 'other',
      );
      expect(receipt.formattedAmount, '\$100.00');
    });

    test('formattedDate returns correct format', () {
      final receipt = Receipt(
        vendorName: 'Test',
        amount: 10,
        date: DateTime(2026, 6, 5),
        category: 'other',
      );
      expect(receipt.formattedDate, 'Jun 5, 2026');
    });

    test('formattedDate handles all months', () {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      for (var i = 0; i < 12; i++) {
        final receipt = Receipt(
          vendorName: 'Test',
          amount: 10,
          date: DateTime(2026, i + 1, 15),
          category: 'other',
        );
        expect(receipt.formattedDate, '${months[i]} 15, 2026');
      }
    });

    test('monthYearKey returns uppercase month + year', () {
      final receipt = Receipt(
        vendorName: 'Test',
        amount: 10,
        date: DateTime(2026, 6, 5),
        category: 'other',
      );
      expect(receipt.monthYearKey, 'JUNE 2026');
    });

    test('monthYearKey handles January', () {
      final receipt = Receipt(
        vendorName: 'Test',
        amount: 10,
        date: DateTime(2026, 1, 1),
        category: 'other',
      );
      expect(receipt.monthYearKey, 'JANUARY 2026');
    });

    test('toCsvRow contains all expected fields', () {
      final receipt = Receipt(
        vendorName: 'Starbucks',
        amount: 5.75,
        date: DateTime(2026, 6, 5),
        category: 'meals',
        note: 'Client meeting',
      );
      final row = receipt.toCsvRow();
      expect(row['Date'], 'Jun 5, 2026');
      expect(row['Vendor'], 'Starbucks');
      expect(row['Category'], 'meals');
      expect(row['Amount'], '5.75');
      expect(row['Note'], 'Client meeting');
    });

    test('toCsvRow handles null note', () {
      final receipt = Receipt(
        vendorName: 'Test',
        amount: 10,
        date: DateTime(2026, 1, 1),
        category: 'other',
      );
      final row = receipt.toCsvRow();
      expect(row['Note'], '');
    });

    test('csvHeaders returns correct columns', () {
      expect(Receipt.csvHeaders, [
        'Date',
        'Vendor',
        'Category',
        'Amount',
        'Note',
      ]);
    });

    test('fields are mutable after creation', () {
      final receipt = Receipt(
        vendorName: 'Original',
        amount: 10,
        date: DateTime(2026, 1, 1),
        category: 'other',
      );
      receipt.vendorName = 'Updated';
      receipt.amount = 20;
      receipt.category = 'meals';
      receipt.note = 'New note';

      expect(receipt.vendorName, 'Updated');
      expect(receipt.amount, 20);
      expect(receipt.category, 'meals');
      expect(receipt.note, 'New note');
    });
  });
}
