import Flutter
import StoreKit

private enum ReceiptSnapPurchaseError: Error {
    case unverifiedTransaction
}

/// Native StoreKit 2 plugin for In-App Purchases.
/// Handles Method Channel calls from Flutter for subscriptions.
@available(iOS 15.0, *)
class StoreKitManager: NSObject, FlutterPlugin {

    // Product IDs matching App Store Connect configuration
    private static let monthlyId = "com.snapdeduct.pro.monthly"
    private static let annualId  = "com.snapdeduct.pro.annual"
    private static let allowedProductIds = Set([monthlyId, annualId])

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.snapdeduct.storekit/iap",
            binaryMessenger: registrar.messenger()
        )
        let instance = StoreKitManager()
        registrar.addMethodCallDelegate(instance, channel: channel)

        // Start transaction listener immediately so we don't miss purchases
        // made outside the app (e.g. from App Store)
        Task {
            await instance.listenForTransactions()
        }
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task {
            switch call.method {
            case "getProducts":
                await fetchProducts(result: result)
            case "purchase":
                if let productId = call.arguments as? String {
                    await purchase(productId: productId, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS",
                                        message: "Expected product ID string",
                                        details: nil))
                }
            case "checkEntitlement":
                await checkEntitlement(result: result)
            case "restorePurchases":
                await restorePurchases(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - Product Fetching

    private func fetchProducts(result: @escaping FlutterResult) async {
        do {
            let productIds = [Self.monthlyId, Self.annualId]
            let products = try await Product.products(for: productIds)

            let productList = products.map { product -> [String: Any] in
                return [
                    "id": product.id,
                    "displayName": product.displayName,
                    "description": product.description,
                    "price": Double(truncating: product.price as NSNumber),
                    "displayPrice": product.displayPrice,
                    "subscriptionPeriod": product.subscription?.subscriptionPeriod.debugDescription ?? "N/A",
                ]
            }

            result(productList)
        } catch {
            result(FlutterError(code: "PRODUCTS_FAILED",
                                message: error.localizedDescription,
                                details: nil))
        }
    }

    // MARK: - Purchase

    private func purchase(productId: String, result: @escaping FlutterResult) async {
        guard Self.allowedProductIds.contains(productId) else {
            result(FlutterError(code: "INVALID_PRODUCT",
                                message: "This product is not offered by ReceiptSnap.",
                                details: nil))
            return
        }
        do {
            let products = try await Product.products(for: [productId])
            guard let product = products.first else {
                result(FlutterError(code: "PRODUCT_NOT_FOUND",
                                    message: "Product '\(productId)' not found",
                                    details: nil))
                return
            }

            let purchaseResult = try await product.purchase()

            switch purchaseResult {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)
                await transaction.finish()
                result(["status": "purchased", "productId": transaction.productID])

            case .userCancelled:
                result(["status": "cancelled"])

            case .pending:
                result(["status": "pending"])

            @unknown default:
                result(["status": "unknown"])
            }

        } catch {
            result(FlutterError(code: "PURCHASE_FAILED",
                                message: error.localizedDescription,
                                details: nil))
        }
    }

    // MARK: - Entitlement Check

    private func checkEntitlement(result: @escaping FlutterResult) async {
        var isPro = false
        var productId: String? = nil
        var expiryDate: String? = nil

        for await verification in Transaction.currentEntitlements {
            if case let .verified(transaction) = verification {
                if transaction.productID == Self.monthlyId ||
                   transaction.productID == Self.annualId,
                   transaction.revocationDate == nil {

                    // Check if subscription has expired
                    if let expires = transaction.expirationDate, expires < Date() {
                        continue // expired
                    }

                    isPro = true
                    productId = transaction.productID
                    if let expires = transaction.expirationDate {
                        let formatter = ISO8601DateFormatter()
                        expiryDate = formatter.string(from: expires)
                    }
                    break
                }
            }
        }

        result([
            "isPro": isPro,
            "productId": productId as Any,
            "expiryDate": expiryDate as Any,
        ])
    }

    // MARK: - Restore

    private func restorePurchases(result: @escaping FlutterResult) async {
        // Sync with App Store
        do {
            try await AppStore.sync()
        } catch {
            // sync may fail on simulator — continue with local entitlements
        }
        await checkEntitlement(result: result)
    }

    // MARK: - Transaction Listener

    /// Listen for transactions that arrive outside the purchase flow
    /// (e.g., family sharing, renewals, App Store purchases).
    private func listenForTransactions() async {
        for await verification in Transaction.updates {
            if case let .verified(transaction) = verification {
                if Self.allowedProductIds.contains(transaction.productID) {
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Verification Helper

    private func checkVerified<T>(_ verification: VerificationResult<T>) throws -> T {
        switch verification {
        case .unverified:
            throw ReceiptSnapPurchaseError.unverifiedTransaction
        case .verified(let safe):
            return safe
        }
    }
}
