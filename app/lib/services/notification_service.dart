import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const _mileageNotifyId = 100;

  static Future<void> init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  static Future<bool> requestPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: false, sound: false) ?? false;
    }
    return true;
  }

  static Future<void> scheduleMileageReminder() async {
    await _plugin.cancel(id: _mileageNotifyId);
    await _plugin.periodicallyShow(
      id: _mileageNotifyId,
      title: 'Any business driving today?',
      body: 'Tap to log your miles — \$0.70/mile adds up fast.',
      repeatInterval: RepeatInterval.daily,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelMileageReminder() async {
    await _plugin.cancel(id: _mileageNotifyId);
  }
}
