import Flutter
import UIKit

public class VisionOcrPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.snapdeduct.app/ocr", binaryMessenger: registrar.messenger())
        let instance = VisionOcrPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "recognizeText",
              let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
            result(FlutterMethodNotImplemented)
            return
        }
        VisionOCR.recognize(imagePath: path) { text in
            result(text ?? "")
        }
    }
}
