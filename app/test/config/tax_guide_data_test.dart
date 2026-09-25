import 'package:flutter_test/flutter_test.dart';
import 'package:receiptsnap/config/tax_guide_data.dart';

void main() {
  test('guide covers broad Schedule C expenses and common pitfalls', () {
    expect(TaxGuideData.expenseEntries.length, greaterThanOrEqualTo(20));
    expect(TaxGuideData.pitfallEntries.length, greaterThanOrEqualTo(14));
  });

  test('guide entries have unique titles and official IRS sources', () {
    final entries = [
      ...TaxGuideData.expenseEntries,
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

  test('guide includes the midyear 2026 mileage change', () {
    final vehicle = TaxGuideData.expenseEntries.singleWhere(
      (entry) => entry.title == 'Vehicle and local transportation',
    );

    expect(vehicle.details, contains('72.5¢'));
    expect(vehicle.details, contains('76¢'));
  });
}
