import Flutter
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
        guard let image = UIImage(contentsOfFile: imagePath)?.cgImage else {
            result(FlutterError(code: "IMAGE_LOAD_FAILED",
                                message: "Could not load image at \(imagePath)",
                                details: nil))
            return
        }

        let request = VNRecognizeTextRequest { [weak self] request, error in
            if let error = error {
                result(FlutterError(code: "OCR_FAILED",
                                    message: error.localizedDescription,
                                    details: nil))
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                result([:] as [String: Any])
                return
            }
            let parsed = self?.parseReceipt(from: observations) ?? [:]
            result(parsed)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"]
        request.minimumTextHeight = 0.01 // filter out noise

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                result(FlutterError(code: "OCR_FAILED",
                                    message: error.localizedDescription,
                                    details: nil))
            }
        }
    }

    /// Parse VNRecognizedTextObservations into structured receipt data.
    private func parseReceipt(from observations: [VNRecognizedTextObservation]) -> [String: Any] {
        let lines = observations
            .compactMap { $0.topCandidates(1).first?.string.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var vendor = ""
        var total: Double?
        var date: String?
        var lineItems: [[String: Any]] = []

        // Heuristic: first meaningful line → vendor; lines with $ → amounts; date regex → date
        for line in lines {
            // Vendor: first non-date-ish, non-amount-ish line
            if vendor.isEmpty && !looksLikeAmount(line) && !looksLikeDate(line) && line.count > 2 {
                vendor = line
                continue
            }

            // Date
            if date == nil, let foundDate = extractDate(from: line) {
                date = foundDate
                continue
            }

            // Amounts
            let amounts = extractAmounts(from: line)
            for amount in amounts {
                lineItems.append(["description": line, "amount": amount])
            }
        }

        // Total: the last/largest amount
        if let biggest = lineItems.map({ $0["amount"] as? Double ?? 0 }).max(), biggest > 0 {
            total = biggest
        }

        // Category guess
        let category = guessCategory(vendor: vendor)

        // Confidence
        let avgConfidence = observations.compactMap { $0.topCandidates(1).first?.confidence }.reduce(0, +)
            / Float(max(observations.count, 1))

        return [
            "vendor": vendor,
            "total": total as Any,
            "date": date as Any,
            "lineItems": lineItems,
            "category": category,
            "confidence": Double(avgConfidence),
            "rawText": lines.joined(separator: "\n"),
        ]
    }

    // MARK: - Helpers

    private func looksLikeAmount(_ text: String) -> Bool {
        let pattern = #/\$?\s*\d+[,.]?\d*\s*(CREDIT|DEBIT)?/#
        return text.contains(pattern)
    }

    private func looksLikeDate(_ text: String) -> Bool {
        let patterns = [
            #/\d{1,2}[/-]\d{1,2}[/-]\d{2,4}/#,
            #/\d{4}[/-]\d{1,2}[/-]\d{1,2}/#,
            #/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{1,2},?\s*\d{4}/#,
        ]
        return patterns.contains { text.contains($0) }
    }

    private func extractDate(from text: String) -> String? {
        let patterns = [
            #/\d{1,2}[/-]\d{1,2}[/-]\d{2,4}/#,
            #/\d{4}[/-]\d{1,2}[/-]\d{1,2}/#,
            #/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{1,2},?\s*\d{4}/#,
        ]
        for pattern in patterns {
            if let match = text.firstMatch(of: pattern) {
                return String(match.output)
            }
        }
        return nil
    }

    private func extractAmounts(from text: String) -> [Double] {
        let pattern = #/\$?\s*(\d{1,3}(?:,\d{3})*\.\d{2})/#
        return text.matches(of: pattern).compactMap {
            let raw = String($0.output.1)
            let cleaned = raw.replacingOccurrences(of: ",", with: "")
            return Double(cleaned)
        }
    }

    private func guessCategory(vendor: String) -> String {
        let lower = vendor.lowercased()
        let keywords: [(String, [String])] = [
            ("food_dining",    ["starbucks", "mcdonald", "chipotle", "restaurant", "cafe", "door dash", "ubereats", "grubhub"]),
            ("transportation", ["uber", "lyft", "gas", "shell", "chevron", "parking", "toll", "transit"]),
            ("utilities",      ["verizon", "at&t", "comcast", "electric", "water", "internet", "phone"]),
            ("software",       ["adobe", "google", "apple", "microsoft", "dropbox", "slack", "notion", "github"]),
            ("office_supply",  ["staples", "officedepot", "amazon", "walmart", "target"]),
            ("travel",         ["airbnb", "hotel", "delta", "united", "american air", "southwest"]),
            ("rent",           ["wework", "regus", "industrious"]),
            ("insurance",      ["geico", "progressive", "state farm", "allstate"]),
        ]
        for (cat, terms) in keywords {
            if terms.contains(where: { lower.contains($0) }) {
                return cat
            }
        }
        return "other"
    }
}
