import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/receipt.dart';
import 'providers/receipt_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/insights_provider.dart';
import 'services/notification_service.dart';
import 'services/irs_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ReceiptAdapter());
  await Hive.openBox<Receipt>('receipts');
  await Hive.openBox('settings');
  await IrsConfig.init();
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReceiptProvider()..loadReceipts()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()..init()),
        ChangeNotifierProvider(create: (_) => InsightsProvider()..init()),
      ],
      child: const SnapDeductApp(),
    ),
  );
}
