import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Custom StoreKit 2 bridge. OCR is provided by the Flutter ML Kit plugin.
    if let storeKitRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "StoreKitManager") {
      StoreKitManager.register(with: storeKitRegistrar)
    }
  }
}
