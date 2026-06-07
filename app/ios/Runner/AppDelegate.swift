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
    let visionRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "VisionOcrPlugin")
    VisionOcrPlugin.register(with: visionRegistrar)

    if #available(iOS 15.0, *) {
      let storeKitRegistrar = engineBridge.pluginRegistry.registrar(forPlugin: "StoreKitManager")
      StoreKitManager.register(with: storeKitRegistrar)
    }
  }
}
