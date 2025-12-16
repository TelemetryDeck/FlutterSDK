import Flutter
import UIKit
import TelemetryDeck

public class TelemetrydecksdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "telemetrydecksdk", binaryMessenger: registrar.messenger())
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
            TelemetryDeck.generateNewSession()
            result(nil)
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
     * @see <a href="https://telemetrydeck.com/docs/articles/navigation-signals/">Navigation Signals</a>
     * */
    private func nativeNavigate(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let sourcePath = arguments["sourcePath"] as? String,
              let destinationPath = arguments["destinationPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "sourcePath and destinationPath are required", details: nil))
            return
        }
        let clientUser = arguments["clientUser"] as? String
        DispatchQueue.main.async {
            TelemetryDeck.navigationPathChanged(from: sourcePath, to: destinationPath, customUserID: clientUser)
            result(nil)
        }
    }
    
    /**
     * Send a signal that represents a navigation event with a destination and a default source.
     *
     * @see <a href="https://telemetrydeck.com/docs/articles/navigation-signals/">Navigation Signals</a>
     * */
    private func nativeNavigateDestination(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let destinationPath = arguments["destinationPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "destinationPath are required", details: nil))
            return
        }
        let clientUser = arguments["clientUser"] as? String
        DispatchQueue.main.async {
            TelemetryDeck.navigationPathChanged(to: destinationPath, customUserID: clientUser)
            result(nil)
        }
    }
    
    private func nativeStop(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        TelemetryDeck.terminate()
        result(nil)
    }
    
    private func nativeUpdateDefaultUser(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        TelemetryDeck.updateDefaultUserID(to: call.arguments as? String)
        result(nil)
    }
    
    private func nativeQueue(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], let signalType = arguments["signalType"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing required argument signalType", details: nil))
            return
        }

        let clientUser = arguments["clientUser"] as? String
        let additionalPayload = arguments["additionalPayload"] as? [String : String] ?? [:]
        let floatValue = arguments["floatValue"] as? Double

        // do not attempt to send signals if the client is stopped
        if TelemetryManager.isInitialized {
            TelemetryDeck.signal(signalType, parameters: additionalPayload, floatValue: floatValue, customUserID: clientUser)
        }

        result(nil)
    }
    
    private func nativeStartDurationSignal(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], let signalType = arguments["signalType"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing required argument signalType", details: nil))
            return
        }
        
        let parameters = arguments["parameters"] as? [String : String] ?? [:]
        
        // do not attempt to send signals if the client is stopped
        if TelemetryManager.isInitialized {
            DispatchQueue.main.async {
                TelemetryDeck.startDurationSignal(signalType, parameters: parameters)
                result(nil)
            }
        } else {
            result(nil)
        }
    }
    
    private func nativeStopAndSendDurationSignal(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], let signalType = arguments["signalType"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing required argument signalType", details: nil))
            return
        }
        
        let parameters = arguments["parameters"] as? [String : String] ?? [:]
        
        // do not attempt to send signals if the client is stopped
        if TelemetryManager.isInitialized {
            DispatchQueue.main.async {
                TelemetryDeck.stopAndSendDurationSignal(signalType, parameters: parameters)
                result(nil)
            }
        } else {
            result(nil)
        }
    }
    
    private func nativeInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are not a map", details: nil))
            return
        }
        
        // appD is required
        guard let appID: String = arguments["appID"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected value appID is not provided.", details: nil))
            return
        }
        
        // baseURL is optional but part of the `TelemetryManagerConfiguration` initializer
        var baseURL: URL? = nil
        if let apiBaseURL = arguments["apiBaseURL"] as? String, let url = URL(string: apiBaseURL) {
            baseURL = url
        }
        
        
        let salt =  arguments["salt"] as? String
        let namespace = arguments["namespace"] as? String
        let configuration = TelemetryManagerConfiguration.init(
            appID: appID, salt: salt, baseURL: baseURL, namespace: namespace)
        
        // other optional params
        if arguments.keys.contains("defaultUser") {
            configuration.defaultUser = arguments["defaultUser"] as? String
        }
        
        if arguments.keys.contains("debug") {
            if arguments["debug"] as? Bool == true {
                // by default, the library logs with level .info
                configuration.logHandler = LogHandler.standard(.debug)
            }
        }
        
        if arguments.keys.contains("testMode") {
            configuration.testMode = arguments["testMode"] as? Bool == true
        }
        
        if arguments.keys.contains("defaultSignalPrefix") {
            configuration.defaultSignalPrefix = arguments["defaultSignalPrefix"] as? String
        }
        
        if arguments.keys.contains("defaultParameterPrefix") {
            configuration.defaultParameterPrefix = arguments["defaultParameterPrefix"] as? String
        }
        
        if arguments.keys.contains("defaultParameters") {
            let finalValues = arguments["defaultParameters"] as? [String : String] ?? [:]
            configuration.defaultParameters = { finalValues }
        }
        
        TelemetryDeck.initialize(config: configuration)

        result(nil)
    }

    private func nativeAcquiredUser(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let channel = arguments["channel"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "channel is required", details: nil))
            return
        }
        let params = arguments["params"] as? [String: String] ?? [:]
        let customUserID = arguments["customUserID"] as? String
        DispatchQueue.main.async {
            TelemetryDeck.acquiredUser(channel: channel, parameters: params, customUserID: customUserID)
            result(nil)
        }
    }

    private func nativeLeadStarted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let leadId = arguments["leadId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "leadId is required", details: nil))
            return
        }
        let params = arguments["params"] as? [String: String] ?? [:]
        let customUserID = arguments["customUserID"] as? String
        DispatchQueue.main.async {
            TelemetryDeck.leadStarted(leadID: leadId, parameters: params, customUserID: customUserID)
            result(nil)
        }
    }

    private func nativeLeadConverted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let leadId = arguments["leadId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "leadId is required", details: nil))
            return
        }
        let params = arguments["params"] as? [String: String] ?? [:]
        let customUserID = arguments["customUserID"] as? String
        DispatchQueue.main.async {
            TelemetryDeck.leadConverted(leadID: leadId, parameters: params, customUserID: customUserID)
            result(nil)
        }
    }

    private func nativeOnboardingCompleted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are not a map", details: nil))
            return
        }
        let params = arguments["params"] as? [String: String] ?? [:]
        let customUserID = arguments["customUserID"] as? String
        DispatchQueue.main.async {
            TelemetryDeck.onboardingCompleted(parameters: params, customUserID: customUserID)
            result(nil)
        }
    }

    private func nativeCoreFeatureUsed(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let featureName = arguments["featureName"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "featureName is required", details: nil))
            return
        }
        let params = arguments["params"] as? [String: String] ?? [:]
        let customUserID = arguments["customUserID"] as? String
        DispatchQueue.main.async {
            TelemetryDeck.coreFeatureUsed(featureName: featureName, parameters: params, customUserID: customUserID)
            result(nil)
        }
    }

    private func nativePaywallShown(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let reason = arguments["reason"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "reason is required", details: nil))
            return
        }
        let params = arguments["params"] as? [String: String] ?? [:]
        let customUserID = arguments["customUserID"] as? String
        DispatchQueue.main.async {
            TelemetryDeck.paywallShown(reason: reason, parameters: params, customUserID: customUserID)
            result(nil)
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

        let offerID = arguments["offerID"] as? String
        let params = arguments["params"] as? [String: String] ?? [:]
        let customUserID = arguments["customUserID"] as? String

        let signalName: String
        switch eventString {
        case "freeTrialStarted":
            signalName = "TelemetryDeck.Purchase.freeTrialStarted"
        case "convertedFromFreeTrial":
            signalName = "TelemetryDeck.Purchase.convertedFromFreeTrial"
        default:
            signalName = "TelemetryDeck.Purchase.completed"
        }

        let type: String
        switch purchaseTypeString {
        case "subscription":
            type = "subscription"
        default:
            type = "one-time-purchase"
        }

        var purchaseParams: [String: String] = [
            "TelemetryDeck.Purchase.type": type,
            "TelemetryDeck.Purchase.countryCode": countryCode,
            "TelemetryDeck.Purchase.productID": productID,
            "TelemetryDeck.Purchase.currencyCode": currencyCode
        ]

        if let offerID = offerID {
            purchaseParams["TelemetryDeck.Purchase.offerID"] = offerID
        }

        let mergedParams = purchaseParams.merging(params) { $1 }

        let priceInUSD = Double(priceAmountMicros) / 1_000_000.0

        DispatchQueue.main.async {
            TelemetryDeck.signal(
                signalName,
                parameters: mergedParams,
                floatValue: priceInUSD,
                customUserID: customUserID
            )
            result(nil)
        }
    }

    private func nativeReferralSent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments are not a map", details: nil))
            return
        }
        let receiversCount = arguments["receiversCount"] as? Int ?? 1
        let kind = arguments["kind"] as? String
        let params = arguments["params"] as? [String: String] ?? [:]
        let customUserID = arguments["customUserID"] as? String
        DispatchQueue.main.async {
            TelemetryDeck.referralSent(receiversCount: receiversCount, kind: kind, parameters: params, customUserID: customUserID)
            result(nil)
        }
    }

    private func nativeUserRatingSubmitted(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let rating = arguments["rating"] as? Int else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "rating is required", details: nil))
            return
        }
        let comment = arguments["comment"] as? String
        let params = arguments["params"] as? [String: String] ?? [:]
        let customUserID = arguments["customUserID"] as? String
        DispatchQueue.main.async {
            TelemetryDeck.userRatingSubmitted(rating: rating, comment: comment, parameters: params, customUserID: customUserID)
            result(nil)
        }
    }

    private func nativeErrorOccurred(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let id = arguments["id"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "id is required", details: nil))
            return
        }

        let categoryString = arguments["category"] as? String
        let category: ErrorCategory?
        if let categoryString = categoryString {
            switch categoryString {
            case "thrownException":
                category = .thrownException
            case "userInput":
                category = .userInput
            case "appState":
                category = .appState
            default:
                category = nil
            }
        } else {
            category = nil
        }

        let message = arguments["message"] as? String
        let parameters = arguments["parameters"] as? [String: String] ?? [:]
        let floatValue = arguments["floatValue"] as? Double
        let customUserID = arguments["customUserID"] as? String

        DispatchQueue.main.async {
            TelemetryDeck.errorOccurred(
                id: id,
                category: category,
                message: message,
                parameters: parameters,
                floatValue: floatValue,
                customUserID: customUserID
            )
            result(nil)
        }
    }
}
