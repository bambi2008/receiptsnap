import Flutter
import Foundation
import UserNotifications

/// Schedules user-controlled, on-device tax reminder notifications.
class TaxReminderPlugin: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.receiptsnap.tax_reminders",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(TaxReminderPlugin(), channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestAuthorization":
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            ) { granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(
                            code: "NOTIFICATION_PERMISSION_FAILED",
                            message: error.localizedDescription,
                            details: nil
                        ))
                    } else {
                        result(granted)
                    }
                }
            }

        case "scheduleReminder":
            guard let arguments = call.arguments as? [String: Any],
                  let identifier = arguments["id"] as? String,
                  let title = arguments["title"] as? String,
                  let body = arguments["body"] as? String,
                  let timestamp = arguments["timestamp"] as? NSNumber else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "Missing reminder fields",
                    details: nil
                ))
                return
            }

            let date = Date(timeIntervalSince1970: timestamp.doubleValue / 1000)
            guard date > Date() else {
                result(nil)
                return
            }
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: date
            )
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(
                            code: "SCHEDULE_FAILED",
                            message: error.localizedDescription,
                            details: nil
                        ))
                    } else {
                        result(nil)
                    }
                }
            }

        case "cancelReminder":
            guard let arguments = call.arguments as? [String: Any],
                  let identifier = arguments["id"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "Missing reminder identifier",
                    details: nil
                ))
                return
            }
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: [identifier])
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
