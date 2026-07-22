import 'package:flutter_test/flutter_test.dart';
import 'package:receiptsnap/config/receipt_tax_insights.dart';
import 'package:receiptsnap/models/receipt.dart';

Receipt receipt(String vendor, String category) => Receipt(
  vendorName: vendor,
  amount: 25,
  date: DateTime(2026, 7, 23),
  category: category,
);

void main() {
  test('maps every known receipt category to a tax review prompt', () {
    const categories = [
      'advertising',
      'meals',
      'travel',
      'office_supplies',
      'software',
      'utilities',
      'rent',
      'shipping',
      'insurance',
    ];

    for (final category in categories) {
      final match = ReceiptTaxInsights.forReceipt(receipt('Vendor', category));
      expect(match.possibleExpense, isNotNull, reason: category);
      expect(match.pitfallLabel, isNotEmpty, reason: category);
      expect(match.action, isNotEmpty, reason: category);
    }
  });

  test('distinguishes rideshare from overnight travel', () {
    final match = ReceiptTaxInsights.forReceipt(receipt('Uber', 'travel'));

    expect(match.possibleExpense!.title, 'Vehicle and local transportation');
    expect(match.pitfall.title, 'Commuting is not business mileage');
  });

  test('flags equipment vendors for asset treatment', () {
    final match = ReceiptTaxInsights.forReceipt(
      receipt('Apple Store', 'office_supplies'),
    );

    expect(match.possibleExpense!.title, contains('Equipment'));
    expect(match.pitfall.title, 'Expense versus asset versus inventory');
  });

  test(
    'unknown category stays a manual review instead of a deduction claim',
    () {
      final match = ReceiptTaxInsights.forReceipt(receipt('Unknown', 'other'));

      expect(match.needsManualReview, isTrue);
      expect(match.expenseLabel, 'Category needs review');
    },
  );
}
