import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/receipt.dart';
import 'providers/receipt_provider.dart';
import 'providers/subscription_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ReceiptAdapter());
  await Hive.openBox<Receipt>('receipts');
  await Hive.openBox('settings');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReceiptProvider()..loadReceipts()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()..init()),
      ],
      child: const ReceiptSnapApp(),
    ),
  );
}
