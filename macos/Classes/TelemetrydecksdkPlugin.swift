import Cocoa
import FlutterMacOS
import TelemetryDeck

public class TelemetrydecksdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "telemetrydecksdk", binaryMessenger: registrar.messenger)
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
        case "generateNewSession":
            TelemetryDeck.generateNewSession()
            result(nil)
        case "updateDefaultUser":
            nativeUpdateDefaultUser(call, result: result)
        case "navigate":
            nativeNavigate(call, result: result)
        case "navigateToDestination":
            nativeNavigateDestination(call, result: result)
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
        TelemetryDeck.navigationPathChanged(from: sourcePath, to: destinationPath, customUserID: clientUser)
        result(nil)
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
        TelemetryDeck.navigationPathChanged(to: destinationPath, customUserID: clientUser)
        result(nil)
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
        
        // do not attempt to send signals if the client is stopped
        if TelemetryManager.isInitialized {
            TelemetryDeck.signal(signalType, parameters: additionalPayload, customUserID: clientUser)
        }
        
        result(nil)
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
        
        let configuration = TelemetryManagerConfiguration.init(
            appID: appID, salt: nil, baseURL: baseURL)
        
        // other optional params
        if arguments.keys.contains("defaultUser") {
            configuration.defaultUser = arguments["defaultUser"] as? String
        }
        
        if arguments.keys.contains("debug") {
            if arguments["debug"] as? Bool == true {
                // by default, the library logs with level .info
                configuration.logHandler = LogHandler.stdout(.debug)
            }
        }
        
        if arguments.keys.contains("testMode") {
            configuration.testMode = arguments["testMode"] as? Bool == true
        }
        
        TelemetryDeck.initialize(config: configuration)
        
        result(nil)
    }
}
