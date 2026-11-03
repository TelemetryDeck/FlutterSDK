#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import Cocoa
import FlutterMacOS
#endif
import TelemetryDeck

public class TelemetrydecksdkPlugin: NSObject, FlutterPlugin {
    private var isRunning = false
    private var pendingOperation: Task<Void, Never>?

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let messenger = registrar.messenger()
        #elseif os(macOS)
        let messenger = registrar.messenger
        #endif
        let channel = FlutterMethodChannel(name: "telemetrydecksdk", binaryMessenger: messenger)
        let instance = TelemetrydecksdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            nativeInitialize(call, result: result)
        case "stop":
            nativeStop(call, result: result)
        case "send":
            nativeQueue(call, result: result)
        case "startDurationSignal":
            nativeStartDurationSignal(call, result: result)
        case "stopAndSendDurationSignal":
            nativeStopAndSendDurationSignal(call, result: result)
        case "generateNewSession":
            runWhenStarted(result) {
                await TelemetryDeck.newSession()
            }
        case "updateDefaultUser":
            nativeUpdateDefaultUser(call, result: result)
        case "navigate":
            nativeNavigate(call, result: result)
        case "navigateToDestination":
            nativeNavigateDestination(call, result: result)
        case "acquiredUser":
            nativeAcquiredUser(call, result: result)
        case "leadStarted":
            nativeLeadStarted(call, result: result)
        case "leadConverted":
            nativeLeadConverted(call, result: result)
        case "onboardingCompleted":
            nativeOnboardingCompleted(call, result: result)
        case "coreFeatureUsed":
            nativeCoreFeatureUsed(call, result: result)
        case "paywallShown":
            nativePaywallShown(call, result: result)
        case "purchaseCompleted":
            nativePurchaseCompleted(call, result: result)
        case "referralSent":
            nativeReferralSent(call, result: result)
        case "userRatingSubmitted":
            nativeUserRatingSubmitted(call, result: result)
        case "errorOccurred":
            nativeErrorOccurred(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /**
     * Send a signal that represents a navigation event with a source and a destination.
     *
     * @see <a href="https://telemetrydeck.com/docs/articles/navigation-events/">Navigation Signals</a>
     * */
    private func nativeNavigate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let sourcePath = arguments["sourcePath"] as? String,
              let destinationPath = arguments["destinationPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "sourcePath and destinationPath are required", details: nil))
            return
        }
        let clientUser = arguments["clientUser"] as? String
        runWhenStarted(result) {
            await TelemetryDeck.navigationPathChanged(from: sourcePath, to: destinationPath, customUserID: clientUser)
        }
    }

    /**
     * Send a signal that represents a navigation event with a destination and a default source.
     *
     * @see <a href="https://telemetrydeck.com/docs/articles/navigation-events/">Navigation Signals</a>
     * */
    private func nativeNavigateDestination(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let destinationPath = arguments["destinationPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "destinationPath is required", details: nil))
            return
        }
        let clientUser = arguments["clientUser"] as? String
        runWhenStarted(result) {
            await TelemetryDeck.navigationPathChanged(to: destinationPath, customUserID: clientUser)
        }
    }

    private func nativeStop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        isRunning = false
        enqueue {
            await TelemetryDeck.terminate()
            result(nil)
        }
    }

    /// Runs `operation` after every previously enqueued operation has finished, so native calls keep the order of the Dart calls.
    private func enqueue(_ operation: @escaping @Sendable () async -> Void) {
        let previous = pendingOperation
        pendingOperation = Task {
            await previous?.value
            await operation()
        }
    }

    private func runWhenStarted(_ result: @escaping FlutterResult, _ operation: @escaping @Sendable () async -> Void) {
        guard isRunning else {
            result(nil)
            return
        }
        enqueue {
            await operation()
            result(nil)
        }
    }

    private func nativeUpdateDefaultUser(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let user = call.arguments as? String
        runWhenStarted(result) {
            await TelemetryDeck.setUserIdentifier(user)
        }
    }

    private func nativeQueue(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], let signalType = arguments["signalType"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing required argument signalType", details: nil))
            return
        }

        let clientUser = arguments["clientUser"] as? String
        let additionalPayload = arguments["additionalPayload"] as? [String : String] ?? [:]
        let floatValue = arguments["floatValue"] as? Double

        runWhenStarted(result) {
            await TelemetryDeck.event(signalType, parameters: EventParameters(additionalPayload), floatValue: floatValue, customUserID: clientUser)
        }
    }

    private func nativeStartDurationSignal(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], let signalType = arguments["signalType"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing required argument signalType", details: nil))
            return
        }

        let parameters = arguments["parameters"] as? [String : String] ?? [:]

        runWhenStarted(result) {
            await TelemetryDeck.startDurationEvent(signalType, parameters: EventParameters(parameters), includeBackgroundTime: false)
        }
    }

    private func nativeStopAndSendDurationSignal(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], let signalType = arguments["signalType"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing required argument signalType", details: nil))
            return
        }

        let parameters = arguments["parameters"] as? [String : String] ?? [:]

        runWhenStarted(result) {
            await TelemetryDeck.stopAndSendDurationEvent(signalType, parameters: EventParameters(parameters))
        }
    }

    private func nativeInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are not a map", details: nil))
            return
        }

        // appID is required
        guard let appID: String = arguments["appID"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected value appID is not provided.", details: nil))
            return
        }

        // namespace is required
        guard let namespace = arguments["namespace"] as? String, !namespace.isEmpty else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected value namespace is not provided.", details: nil))
            return
        }

        let apiBaseURL = (arguments["apiBaseURL"] as? String).flatMap(URL.init(string:))
        let config = TelemetryDeck.Config(
            appID: appID,
            namespace: namespace,
            apiBaseURL: apiBaseURL ?? URL(string: "https://nom.telemetrydeck.com")!,
            salt: arguments["salt"] as? String ?? ""
        )

        let defaultParameters = arguments["defaultParameters"] as? [String: String] ?? [:]
        let sdkMetadata = defaultParameters.filter { $0.key.hasPrefix(SDKMetadataProcessor.parameterPrefix) }
        let processors = TelemetryDeck.defaultProcessors(
            defaultUser: arguments["defaultUser"] as? String,
            testMode: arguments["testMode"] as? Bool,
            eventPrefix: arguments["defaultSignalPrefix"] as? String,
            parameterPrefix: arguments["defaultParameterPrefix"] as? String,
            defaultParameters: EventParameters(defaultParameters.filter { !$0.key.hasPrefix(SDKMetadataProcessor.parameterPrefix) })
        ) + [SDKMetadataProcessor(parameters: sdkMetadata)]

        // by default, the library logs with level .info
        let logger: (any Logging)? = (arguments["debug"] as? Bool == true) ? DefaultLogger(minimumLevel: .debug) : nil

        isRunning = true
        enqueue {
            do {
                try await TelemetryDeck.initialize(configuration: config, processors: processors, logger: logger)
                result(nil)
            } catch {
                await MainActor.run { self.isRunning = false }
                result(FlutterError(code: "INIT_FAILED", message: error.localizedDescription, details: nil))
            }
        }
    }

    private func nativeAcquiredUser(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let channel = arguments["channel"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "channel is required", details: nil))
            return
        }
        let params = EventParameters(arguments["params"] as? [String: String] ?? [:])
        let customUserID = arguments["customUserID"] as? String
        runWhenStarted(result) {
            await TelemetryDeck.acquiredUser(channel: channel, parameters: params, customUserID: customUserID)
        }
    }

    private func nativeLeadStarted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let leadId = arguments["leadId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "leadId is required", details: nil))
            return
        }
        let params = EventParameters(arguments["params"] as? [String: String] ?? [:])
        let customUserID = arguments["customUserID"] as? String
        runWhenStarted(result) {
            await TelemetryDeck.leadStarted(leadID: leadId, parameters: params, customUserID: customUserID)
        }
    }

    private func nativeLeadConverted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let leadId = arguments["leadId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "leadId is required", details: nil))
            return
        }
        let params = EventParameters(arguments["params"] as? [String: String] ?? [:])
        let customUserID = arguments["customUserID"] as? String
        runWhenStarted(result) {
            await TelemetryDeck.leadConverted(leadID: leadId, parameters: params, customUserID: customUserID)
        }
    }

    private func nativeOnboardingCompleted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are not a map", details: nil))
            return
        }
        let params = EventParameters(arguments["params"] as? [String: String] ?? [:])
        let customUserID = arguments["customUserID"] as? String
        runWhenStarted(result) {
            await TelemetryDeck.onboardingCompleted(parameters: params, customUserID: customUserID)
        }
    }

    private func nativeCoreFeatureUsed(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let featureName = arguments["featureName"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "featureName is required", details: nil))
            return
        }
        let params = EventParameters(arguments["params"] as? [String: String] ?? [:])
        let customUserID = arguments["customUserID"] as? String
        runWhenStarted(result) {
            await TelemetryDeck.coreFeatureUsed(featureName: featureName, parameters: params, customUserID: customUserID)
        }
    }

    private func nativePaywallShown(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let reason = arguments["reason"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "reason is required", details: nil))
            return
        }
        let params = EventParameters(arguments["params"] as? [String: String] ?? [:])
        let customUserID = arguments["customUserID"] as? String
        runWhenStarted(result) {
            await TelemetryDeck.paywallShown(reason: reason, parameters: params, customUserID: customUserID)
        }
    }

    private func nativePurchaseCompleted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let eventString = arguments["event"] as? String,
              let countryCode = arguments["countryCode"] as? String,
              let productID = arguments["productID"] as? String,
              let purchaseTypeString = arguments["purchaseType"] as? String,
              let priceAmountMicros = arguments["priceAmountMicros"] as? Int,
              let currencyCode = arguments["currencyCode"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "event, countryCode, productID, purchaseType, priceAmountMicros, and currencyCode are required", details: nil))
            return
        }

        let customUserID = arguments["customUserID"] as? String

        var params = EventParameters(arguments["params"] as? [String: String] ?? [:])
        if let offerID = arguments["offerID"] as? String {
            params["TelemetryDeck.Purchase.offerID"] = offerID
        }

        let type: TelemetryDeck.PurchaseType = purchaseTypeString == "subscription" ? .subscription : .oneTimePurchase
        let price = Decimal(priceAmountMicros) / 1_000_000

        runWhenStarted(result) { [params] in
            switch eventString {
            case "freeTrialStarted":
                await TelemetryDeck.freeTrialStarted(
                    productID: productID,
                    type: type,
                    currencyCode: currencyCode,
                    countryCode: countryCode,
                    parameters: params,
                    customUserID: customUserID
                )
            case "convertedFromFreeTrial":
                await TelemetryDeck.convertedFromTrial(
                    productID: productID,
                    type: type,
                    price: price,
                    currencyCode: currencyCode,
                    countryCode: countryCode,
                    parameters: params,
                    customUserID: customUserID
                )
            default:
                await TelemetryDeck.purchaseCompleted(
                    productID: productID,
                    type: type,
                    price: price,
                    currencyCode: currencyCode,
                    countryCode: countryCode,
                    parameters: params,
                    customUserID: customUserID
                )
            }
        }
    }

    private func nativeReferralSent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are not a map", details: nil))
            return
        }
        let receiversCount = arguments["receiversCount"] as? Int ?? 1
        let kind = arguments["kind"] as? String
        let params = EventParameters(arguments["params"] as? [String: String] ?? [:])
        let customUserID = arguments["customUserID"] as? String
        runWhenStarted(result) {
            await TelemetryDeck.referralSent(receiversCount: receiversCount, kind: kind, parameters: params, customUserID: customUserID)
        }
    }

    private func nativeUserRatingSubmitted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let rating = arguments["rating"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "rating is required", details: nil))
            return
        }
        let comment = arguments["comment"] as? String
        let params = EventParameters(arguments["params"] as? [String: String] ?? [:])
        let customUserID = arguments["customUserID"] as? String
        runWhenStarted(result) {
            await TelemetryDeck.userRatingSubmitted(rating: rating, comment: comment, parameters: params, customUserID: customUserID)
        }
    }

    private func nativeErrorOccurred(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let id = arguments["id"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "id is required", details: nil))
            return
        }

        let category: ErrorCategory?
        switch arguments["category"] as? String {
        case "thrownException":
            category = .thrownException
        case "userInput":
            category = .userInput
        case "appState":
            category = .appState
        default:
            category = nil
        }

        let message = arguments["message"] as? String
        let params = EventParameters(arguments["parameters"] as? [String: String] ?? [:])
        let floatValue = arguments["floatValue"] as? Double
        let customUserID = arguments["customUserID"] as? String

        runWhenStarted(result) {
            await TelemetryDeck.errorOccurred(
                id: id,
                category: category,
                message: message,
                parameters: params,
                floatValue: floatValue,
                customUserID: customUserID
            )
        }
    }
}
