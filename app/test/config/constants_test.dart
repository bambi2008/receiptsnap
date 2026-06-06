import 'package:flutter_test/flutter_test.dart';
import 'package:receiptsnap/config/constants.dart';

void main() {
  group('AppConstants', () {
    test('appName is ReceiptSnap', () {
      expect(AppConstants.appName, 'ReceiptSnap');
    });

    test('freeReceiptLimit is 50', () {
      expect(AppConstants.freeReceiptLimit, 50);
    });

    test('monthlyPrice is 4.99', () {
      expect(AppConstants.monthlyPrice, 4.99);
    });

    test('annualPrice gives ~33% discount vs monthly', () {
      // $4.99 * 12 = $59.88, annual is $39.99
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
