import 'package:flutter_test/flutter_test.dart';
import 'package:receiptsnap/config/tax_guide_data.dart';

void main() {
  test('guide covers broad Schedule C expenses and common pitfalls', () {
    expect(TaxGuideData.expenseEntries.length, greaterThanOrEqualTo(20));
    expect(TaxGuideData.creditEntries.length, greaterThanOrEqualTo(12));
    expect(TaxGuideData.pitfallEntries.length, greaterThanOrEqualTo(14));
  });

  test('guide entries have unique titles and official IRS sources', () {
    final entries = [
      ...TaxGuideData.expenseEntries,
      ...TaxGuideData.creditEntries,
      ...TaxGuideData.pitfallEntries,
    ];
    final titles = entries.map((entry) => entry.title).toSet();
    final checklistIds = entries.map((entry) => entry.checklistId).toSet();

    expect(titles.length, entries.length);
    expect(checklistIds.length, entries.length);
    for (final entry in entries) {
      expect(entry.overview.trim(), isNotEmpty);
      expect(entry.details.trim(), isNotEmpty);
      expect(entry.pitfall.trim(), isNotEmpty);
      expect(Uri.parse(entry.sourceUrl).host, 'www.irs.gov');
    }
  });

  test('credit checklist covers core freelancer household credits', () {
    final titles = TaxGuideData.creditEntries
        .map((entry) => entry.title)
        .toSet();

    expect(titles, contains('Earned Income Tax Credit (EITC)'));
    expect(
      titles,
      contains('Child Tax Credit and Credit for Other Dependents'),
    );
    expect(titles, contains('Child and Dependent Care Credit'));
    expect(titles, contains('Premium Tax Credit for Marketplace coverage'));
    expect(
      titles,
      contains('Education credits: AOTC or Lifetime Learning Credit'),
    );
    expect(titles, contains('Retirement Savings Contributions Credit'));
  });

  test('credit checklist warns that common energy credits expired', () {
    final energy = TaxGuideData.creditEntries.singleWhere(
      (entry) => entry.title == 'Expired energy credits and old carryforwards',
    );

    expect(energy.details, contains('September 30, 2025'));
    expect(energy.details, contains('December 31, 2025'));
  });

  test('guide includes the midyear 2026 mileage change', () {
    final vehicle = TaxGuideData.expenseEntries.singleWhere(
      (entry) => entry.title == 'Vehicle and local transportation',
    );

    expect(vehicle.details, contains('72.5¢'));
    expect(vehicle.details, contains('76¢'));
  });
}
