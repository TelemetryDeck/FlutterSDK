import Flutter
import UIKit
import TelemetryClient

public class TelemetrydecksdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "telemetrydecksdk", binaryMessenger: registrar.messenger())
        let instance = TelemetrydecksdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "initialize":
            nativeInitialize(call, result: result)
        case "send":
            nativeQueue(call, result: result)
        case "generateNewSession":
            TelemetryManager.generateNewSession()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func nativeQueue(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any], let signalType = arguments["signalType"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing required argument signalType", details: nil))
            return
        }
        
        let clientUser = arguments["clientUser"] as? String
        let additionalPayload = arguments["additionalPayload"] as? [String : String] ?? [:]
        
        TelemetryManager.send(signalType, for: clientUser, with: additionalPayload)
        // success
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
        
        // other optional params
        let defaultUser = arguments["defaultUser"] as? String
        let debug = arguments["debug"] as? Bool == true
        let testMode = arguments["testMode"] as? Bool == true
        
        var configuration = TelemetryManagerConfiguration.init(appID: appID, salt: nil, baseURL: baseURL)
        
        configuration.defaultUser = defaultUser
        
        if debug {
            // by default, the library logs with level .info
            configuration.logHandler = LogHandler.stdout(.debug)
        }
        
        if testMode {
            configuration.testMode = true
        }
        
        TelemetryManager.initialize(with: configuration)
        // success
        result(nil)
    }
}
