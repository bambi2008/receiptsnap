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

    // Custom plugins: Vision OCR + StoreKit 2
    guard let visionRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "VisionOcrPlugin") else {
      return
    }
    VisionOcrPlugin.register(with: visionRegistrar)

    if #available(iOS 15.0, *) {
      guard let storeKitRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "StoreKitManager") else {
        return
      }
      StoreKitManager.register(with: storeKitRegistrar)
    }
  }
}
