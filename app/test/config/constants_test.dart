import 'package:flutter_test/flutter_test.dart';
import 'package:receiptsnap/config/constants.dart';

void main() {
  group('AppConstants', () {
    test('appName is SnapDeduct', () {
      expect(AppConstants.appName, 'SnapDeduct');
    });

    test('freeReceiptLimit is 50', () {
      expect(AppConstants.freeReceiptLimit, 50);
    });

    test('monthlyPrice is 8.99', () {
      expect(AppConstants.monthlyPrice, 8.99);
    });

    test('annualPrice gives discount vs monthly', () {
      // \$8.99 × 12 = \$107.88, annual is \$89.99 (~17% off)
      final monthlyAnnual = AppConstants.monthlyPrice * 12;
      expect(AppConstants.annualPrice, lessThan(monthlyAnnual));
    });

    test('appVersion is 1.0.0', () {
      expect(AppConstants.appVersion, '1.0.0');
    });

    test('storage keys are defined', () {
      expect(AppConstants.onboardingKey, 'has_onboarded');
      expect(AppConstants.subscriptionKey, 'is_pro');
      expect(AppConstants.receiptCountKey, 'receipt_count');
    });

    test('support email is defined', () {
      expect(AppConstants.supportEmail, contains('@'));
    });

    test('privacy and terms URLs defined', () {
      expect(AppConstants.privacyUrl, isNotEmpty);
      expect(AppConstants.termsUrl, isNotEmpty);
    });
  });
}
