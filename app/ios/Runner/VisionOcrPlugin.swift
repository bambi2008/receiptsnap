import Flutter
import ImageIO
import UIKit
import Vision

/// Native OCR plugin using Apple's Vision framework.
/// Handles Method Channel calls from Flutter to recognize receipt text.
class VisionOcrPlugin: NSObject, FlutterPlugin {

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.receiptsnap.vision/ocr",
            binaryMessenger: registrar.messenger()
        )
        let instance = VisionOcrPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "recognizeText":
            guard let args = call.arguments as? [String: Any],
                  let imagePath = args["imagePath"] as? String else {
                result(FlutterError(code: "INVALID_ARGS",
                                    message: "Expected imagePath key",
                                    details: nil))
                return
            }
            recognizeText(in: imagePath, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - OCR

    private func recognizeText(in imagePath: String, result: @escaping FlutterResult) {
        guard let uiImage = UIImage(contentsOfFile: imagePath),
              let image = uiImage.cgImage else {
            result(FlutterError(code: "IMAGE_LOAD_FAILED",
                                message: "Could not load image at \(imagePath)",
                                details: nil))
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                DispatchQueue.main.async {
                    result(FlutterError(code: "OCR_FAILED",
                                        message: error.localizedDescription,
                                        details: nil))
                }
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                DispatchQueue.main.async {
                    result(["rawText": "", "confidence": 0.0] as [String: Any])
                }
                return
            }
            let lines = observations
                .compactMap { $0.topCandidates(1).first?.string.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            let confidences = observations.compactMap { $0.topCandidates(1).first?.confidence }
            let confidence = confidences.reduce(0, +) / Float(max(confidences.count, 1))
            DispatchQueue.main.async {
                result([
                    "rawText": lines.joined(separator: "\n"),
                    "confidence": Double(confidence),
                ])
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"]
        request.minimumTextHeight = 0.01 // filter out noise

        let handler = VNImageRequestHandler(
            cgImage: image,
            orientation: cgImageOrientation(from: uiImage.imageOrientation),
            options: [:]
        )
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "OCR_FAILED",
                                        message: error.localizedDescription,
                                        details: nil))
                }
            }
        }
    }

    private func cgImageOrientation(from orientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch orientation {
        case .up: return .up
        case .upMirrored: return .upMirrored
        case .down: return .down
        case .downMirrored: return .downMirrored
        case .left: return .left
        case .leftMirrored: return .leftMirrored
        case .right: return .right
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
