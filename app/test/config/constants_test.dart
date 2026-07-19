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

    test('StoreKit product identifiers are defined', () {
      expect(AppConstants.proMonthlyId, isNotEmpty);
      expect(AppConstants.proAnnualId, isNotEmpty);
      expect(AppConstants.proMonthlyId, isNot(AppConstants.proAnnualId));
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
