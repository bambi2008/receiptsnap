import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:receiptsnap/providers/subscription_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Box<dynamic> settings;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'receiptsnap-subscription-test',
    );
    Hive.init(directory.path);
    settings = await Hive.openBox<dynamic>('subscription_settings');
  });

  tearDown(() async {
    await settings.close();
    await directory.delete(recursive: true);
  });

  test('missing StoreKit bridge fails closed', () async {
    final provider = SubscriptionProvider(settings);
    final result = await provider.purchase('com.snapdeduct.pro.monthly');

    expect(result['status'], 'error');
    expect(provider.isPro, isFalse);
  });

  test('free quota survives provider recreation', () async {
    final first = SubscriptionProvider(settings);
    await first.init();
    await first.incrementReceiptCount();

    final second = SubscriptionProvider(settings);
    await second.init();

    expect(second.receiptCount, 1);
    expect(second.remainingFree, 49);
  });
}
