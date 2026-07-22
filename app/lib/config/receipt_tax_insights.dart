import '../models/receipt.dart';
import 'tax_guide_data.dart';

class ReceiptTaxMatch {
  final TaxGuideEntry? possibleExpense;
  final TaxGuideEntry pitfall;
  final String expenseLabel;
  final String pitfallLabel;
  final String action;

  const ReceiptTaxMatch({
    required this.possibleExpense,
    required this.pitfall,
    required this.expenseLabel,
    required this.pitfallLabel,
    required this.action,
  });

  bool get needsManualReview => possibleExpense == null;
}

class ReceiptTaxInsights {
  static TaxGuideEntry _expense(String title) =>
      TaxGuideData.expenseEntries.firstWhere((entry) => entry.title == title);

  static TaxGuideEntry _pitfall(String title) =>
      TaxGuideData.pitfallEntries.firstWhere((entry) => entry.title == title);

  static ReceiptTaxMatch forReceipt(Receipt receipt) {
    final vendor = receipt.vendorName.toLowerCase();

    if (receipt.category == 'travel' &&
        (vendor.contains('uber') ||
            vendor.contains('lyft') ||
            vendor.contains('taxi'))) {
      return ReceiptTaxMatch(
        possibleExpense: _expense('Vehicle and local transportation'),
        pitfall: _pitfall('Commuting is not business mileage'),
        expenseLabel: 'Local business transportation',
        pitfallLabel: 'Commuting is personal',
        action: 'Add the destination and business purpose; exclude commuting.',
      );
    }

    if ((receipt.category == 'office_supplies' ||
            receipt.category == 'software') &&
        (vendor.contains('apple') ||
            vendor.contains('best buy') ||
            vendor.contains('computer'))) {
      return ReceiptTaxMatch(
        possibleExpense: _expense('Equipment, Section 179 and depreciation'),
        pitfall: _pitfall('Expense versus asset versus inventory'),
        expenseLabel: 'Equipment or depreciable asset',
        pitfallLabel: 'May not be a current expense',
        action:
            'Record what was purchased, when it entered service, and business-use percentage.',
      );
    }

    if (receipt.category == 'insurance' &&
        (vendor.contains('health') ||
            vendor.contains('medical') ||
            vendor.contains('dental') ||
            vendor.contains('kaiser') ||
            vendor.contains('blue cross'))) {
      return ReceiptTaxMatch(
        possibleExpense: _expense('Self-employed health insurance'),
        pitfall: _pitfall('Owner deductions may not belong on Schedule C'),
        expenseLabel: 'Self-employed health insurance',
        pitfallLabel: 'Usually not a Schedule C expense',
        action:
            'Keep the premium record and verify eligibility and Schedule 1 treatment.',
      );
    }

    return switch (receipt.category) {
      'advertising' => ReceiptTaxMatch(
        possibleExpense: _expense('Advertising and marketing'),
        pitfall: _pitfall('“Business” does not automatically mean deductible'),
        expenseLabel: 'Advertising and marketing',
        pitfallLabel: 'Business purpose still matters',
        action:
            'Keep the invoice and note the campaign, audience, or business objective.',
      ),
      'meals' => ReceiptTaxMatch(
        possibleExpense: _expense('Business meals'),
        pitfall: _pitfall('Meals and entertainment are not the same'),
        expenseLabel: 'Possible business meal',
        pitfallLabel: 'Often limited; entertainment differs',
        action:
            'Add who attended, the business relationship, and the business discussion.',
      ),
      'travel' => ReceiptTaxMatch(
        possibleExpense: _expense('Business travel'),
        pitfall: _pitfall('A receipt does not prove business purpose'),
        expenseLabel: 'Possible business travel',
        pitfallLabel: 'Personal days and companion costs',
        action:
            'Add destination, dates, business purpose, and any personal portion.',
      ),
      'office_supplies' => ReceiptTaxMatch(
        possibleExpense: _expense('Office expenses, supplies and software'),
        pitfall: _pitfall('Expense versus asset versus inventory'),
        expenseLabel: 'Office expense or supplies',
        pitfallLabel: 'Asset or inventory treatment may differ',
        action: 'Describe the item and how it was used in the business.',
      ),
      'software' => ReceiptTaxMatch(
        possibleExpense: _expense('Office expenses, supplies and software'),
        pitfall: _pitfall('Mixed business and personal use must be split'),
        expenseLabel: 'Business software or tools',
        pitfallLabel: 'Split personal use',
        action:
            'Note the business workflow and support the business-use percentage.',
      ),
      'utilities' => ReceiptTaxMatch(
        possibleExpense: _expense('Utilities, phone and internet'),
        pitfall: _pitfall('Mixed business and personal use must be split'),
        expenseLabel: 'Phone, internet, or utilities',
        pitfallLabel: 'Only the business portion',
        action:
            'Keep a reasonable usage basis instead of using an unsupported percentage.',
      ),
      'rent' => ReceiptTaxMatch(
        possibleExpense: _expense('Rent and leases'),
        pitfall: _pitfall('“Business” does not automatically mean deductible'),
        expenseLabel: 'Workspace rent or lease',
        pitfallLabel: 'Home-office rules are stricter',
        action:
            'Identify the workspace and do not treat personal housing as ordinary rent.',
      ),
      'shipping' => ReceiptTaxMatch(
        possibleExpense: _expense('Office expenses, supplies and software'),
        pitfall: _pitfall('A receipt does not prove business purpose'),
        expenseLabel: 'Business postage or shipping',
        pitfallLabel: 'Link it to a business shipment',
        action: 'Add the customer, order, project, or other business purpose.',
      ),
      'insurance' => ReceiptTaxMatch(
        possibleExpense: _expense('Business insurance'),
        pitfall: _pitfall('Owner deductions may not belong on Schedule C'),
        expenseLabel: 'Business insurance',
        pitfallLabel: 'Policy type controls treatment',
        action:
            'Identify the coverage and separate owner health premiums from business policies.',
      ),
      _ => ReceiptTaxMatch(
        possibleExpense: null,
        pitfall: _pitfall('“Business” does not automatically mean deductible'),
        expenseLabel: 'Category needs review',
        pitfallLabel: 'Do not assume it is deductible',
        action:
            'Choose the closest category and add what was purchased and why it served the business.',
      ),
    };
  }
}
