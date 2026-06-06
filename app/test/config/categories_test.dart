import 'package:flutter_test/flutter_test.dart';
import 'package:receiptsnap/config/categories.dart';
import 'package:receiptsnap/config/theme.dart';

void main() {
  group('ReceiptCategory', () {
    test('has 10 categories', () {
      expect(categories.length, 10);
    });

    test('each category key is unique', () {
      final keys = categories.map((c) => c.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('each category has non-empty label', () {
      for (final cat in categories) {
        expect(cat.label, isNotEmpty);
      }
    });
  });

  group('categoryMap', () {
    test('contains all category keys', () {
      for (final cat in categories) {
        expect(categoryMap.containsKey(cat.key), true);
      }
    });

    test('maps correct category objects', () {
      expect(categoryMap['meals']!.label, 'Meals');
      expect(categoryMap['travel']!.label, 'Travel');
      expect(categoryMap['software']!.label, 'Software/Tools');
    });

    test('contains exactly 10 entries', () {
      expect(categoryMap.length, 10);
    });
  });

  group('guessCategory', () {
    test('guesses meals for restaurant-related vendors', () {
      expect(guessCategory('Starbucks'), 'meals');
      expect(guessCategory('starbucks'), 'meals');
      expect(guessCategory('Restaurant Le Foo'), 'meals');
      expect(guessCategory('Cafe Nero'), 'meals');
      expect(guessCategory('DoorDash'), 'meals');
      expect(guessCategory('UberEats'), 'meals');
    });

    test('guesses travel for transit/hotel vendors', () {
      expect(guessCategory('Uber'), 'travel');
      expect(guessCategory('Lyft'), 'travel');
      expect(guessCategory('Delta Airlines'), 'travel');
      expect(guessCategory('United'), 'travel');
      expect(guessCategory('Airbnb'), 'travel');
      expect(guessCategory('Hotel California'), 'travel');
    });

    test('guesses software for SaaS/tool vendors', () {
      expect(guessCategory('Adobe'), 'software');
      expect(guessCategory('Notion'), 'software');
      expect(guessCategory('Slack'), 'software');
      expect(guessCategory('GitHub'), 'software');
      expect(guessCategory('Figma'), 'software');
    });

    test('guesses office_supplies for retail vendors', () {
      expect(guessCategory('Amazon'), 'office_supplies');
      expect(guessCategory('Staples'), 'office_supplies');
      expect(guessCategory('Office Depot'), 'office_supplies');
    });

    test('guesses utilities for phone/ISP vendors', () {
      expect(guessCategory('Verizon'), 'utilities');
      expect(guessCategory('AT&T'), 'utilities');
      expect(guessCategory('T-Mobile'), 'utilities');
    });

    test('guesses rent for workspace vendors', () {
      expect(guessCategory('WeWork'), 'rent');
      expect(guessCategory('Regus'), 'rent');
    });

    test('guesses shipping for delivery vendors', () {
      expect(guessCategory('FedEx'), 'shipping');
      expect(guessCategory('UPS'), 'shipping');
      expect(guessCategory('USPS'), 'shipping');
    });

    test('guesses advertising for ad platform vendors', () {
      expect(guessCategory('Google Ads'), 'advertising');
      expect(guessCategory('Facebook Ads'), 'advertising');
      expect(guessCategory('Meta Ads'), 'advertising');
    });

    test('defaults to other for unknown vendors', () {
      expect(guessCategory('Random Store'), 'other');
      expect(guessCategory('Some Guy'), 'other');
      expect(guessCategory(''), 'other');
    });

    test('case-insensitive matching', () {
      expect(guessCategory('UBER'), 'travel');
      expect(guessCategory('StArBuCkS'), 'meals');
      expect(guessCategory('adobe'), 'software');
    });
  });
}
