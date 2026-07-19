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

    // Custom native bridges for StoreKit 2 and on-device Apple Vision OCR.
    if let storeKitRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "StoreKitManager") {
      StoreKitManager.register(with: storeKitRegistrar)
    }
    if let visionRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "VisionOcrPlugin") {
      VisionOcrPlugin.register(with: visionRegistrar)
    }
  }
}
