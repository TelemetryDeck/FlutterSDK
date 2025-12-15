import FlutterMacOS
import Cocoa
import XCTest
import TelemetryDeck

@testable import telemetrydecksdk

class RunnerTests: XCTestCase {
    var plugin: TelemetrydecksdkPlugin!

    override func setUp() {
        super.setUp()
        plugin = TelemetrydecksdkPlugin()
    }

    override func tearDown() {
        plugin = nil
        if TelemetryManager.isInitialized {
            TelemetryDeck.terminate()
        }
        super.tearDown()
    }

    func testStart_withRequiredAppID() {
        let call = FlutterMethodCall(methodName: "start", arguments: [
            "appID": "32CB6574-6732-4238-879F-582FEBEB6536"
        ])

        let expectation = expectation(description: "start completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            XCTAssertTrue(TelemetryManager.isInitialized)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testStart_withMissingAppID_returnsError() {
        let call = FlutterMethodCall(methodName: "start", arguments: [:])

        let expectation = expectation(description: "start returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            XCTAssertEqual(error.message, "Expected value appID is not provided.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testStart_withOptionalParameters() {
        let call = FlutterMethodCall(methodName: "start", arguments: [
            "appID": "32CB6574-6732-4238-879F-582FEBEB6536",
            "apiBaseURL": "https://nom.telemetrydeck.com",
            "salt": "customSalt",
            "namespace": "testNamespace",
            "defaultUser": "testUser",
            "debug": true,
            "testMode": true,
            "defaultSignalPrefix": "Test.",
            "defaultParameterPrefix": "Custom.",
            "defaultParameters": ["key": "value"]
        ])

        let expectation = expectation(description: "start completes with options")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            XCTAssertTrue(TelemetryManager.isInitialized)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testStop() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "stop", arguments: nil)

        let expectation = expectation(description: "stop completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testSend_withRequiredSignalType() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "send", arguments: [
            "signalType": "Test.Event"
        ])

        let expectation = expectation(description: "send completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testSend_withAllParameters() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "send", arguments: [
            "signalType": "Test.Event",
            "clientUser": "testUser123",
            "additionalPayload": ["key1": "value1", "key2": "value2"],
            "floatValue": 42.5
        ])

        let expectation = expectation(description: "send completes with params")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testSend_withMissingSignalType_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "send", arguments: [:])

        let expectation = expectation(description: "send returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            XCTAssertEqual(error.message, "Missing required argument signalType")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testGenerateNewSession() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "generateNewSession", arguments: nil)

        let expectation = expectation(description: "generateNewSession completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testUpdateDefaultUser() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "updateDefaultUser", arguments: "newUserID")

        let expectation = expectation(description: "updateDefaultUser completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testNavigate_withSourceAndDestination() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "navigate", arguments: [
            "sourcePath": "/home",
            "destinationPath": "/profile"
        ])

        let expectation = expectation(description: "navigate completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testNavigate_withMissingParameters_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "navigate", arguments: [
            "sourcePath": "/home"
        ])

        let expectation = expectation(description: "navigate returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            XCTAssertEqual(error.message, "sourcePath and destinationPath are required")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testNavigateToDestination() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "navigateToDestination", arguments: [
            "destinationPath": "/settings"
        ])

        let expectation = expectation(description: "navigateToDestination completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testNavigateToDestination_withMissingDestination_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "navigateToDestination", arguments: [:])

        let expectation = expectation(description: "navigateToDestination returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testAcquiredUser_withChannel() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "acquiredUser", arguments: [
            "channel": "organic"
        ])

        let expectation = expectation(description: "acquiredUser completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testAcquiredUser_withAllParameters() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "acquiredUser", arguments: [
            "channel": "facebook",
            "params": ["campaign": "summer2024"],
            "customUserID": "user123"
        ])

        let expectation = expectation(description: "acquiredUser completes with params")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testAcquiredUser_withMissingChannel_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "acquiredUser", arguments: [:])

        let expectation = expectation(description: "acquiredUser returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            XCTAssertEqual(error.message, "channel is required")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testLeadStarted() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "leadStarted", arguments: [
            "leadId": "lead_12345",
            "params": ["source": "website"],
            "customUserID": "user456"
        ])

        let expectation = expectation(description: "leadStarted completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testLeadStarted_withMissingLeadId_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "leadStarted", arguments: [:])

        let expectation = expectation(description: "leadStarted returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            XCTAssertEqual(error.message, "leadId is required")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testLeadConverted() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "leadConverted", arguments: [
            "leadId": "lead_12345",
            "params": ["value": "100"],
            "customUserID": "user456"
        ])

        let expectation = expectation(description: "leadConverted completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testLeadConverted_withMissingLeadId_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "leadConverted", arguments: [:])

        let expectation = expectation(description: "leadConverted returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            XCTAssertEqual(error.message, "leadId is required")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testOnboardingCompleted() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "onboardingCompleted", arguments: [
            "params": ["steps": "5"],
            "customUserID": "user789"
        ])

        let expectation = expectation(description: "onboardingCompleted completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testCoreFeatureUsed() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "coreFeatureUsed", arguments: [
            "featureName": "darkMode",
            "params": ["enabled": "true"],
            "customUserID": "user123"
        ])

        let expectation = expectation(description: "coreFeatureUsed completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testCoreFeatureUsed_withMissingFeatureName_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "coreFeatureUsed", arguments: [:])

        let expectation = expectation(description: "coreFeatureUsed returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            XCTAssertEqual(error.message, "featureName is required")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testPaywallShown() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "paywallShown", arguments: [
            "reason": "featureAccess",
            "params": ["feature": "premium"],
            "customUserID": "user456"
        ])

        let expectation = expectation(description: "paywallShown completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testPaywallShown_withMissingReason_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "paywallShown", arguments: [:])

        let expectation = expectation(description: "paywallShown returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            XCTAssertEqual(error.message, "reason is required")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testPurchaseCompleted_withDefaultEvent() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "purchaseCompleted", arguments: [
            "event": "completed",
            "countryCode": "US",
            "productID": "com.app.premium",
            "purchaseType": "subscription",
            "priceAmountMicros": 4990000,
            "currencyCode": "USD"
        ])

        let expectation = expectation(description: "purchaseCompleted completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testPurchaseCompleted_withFreeTrialStarted() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "purchaseCompleted", arguments: [
            "event": "freeTrialStarted",
            "countryCode": "DE",
            "productID": "com.app.pro",
            "purchaseType": "subscription",
            "priceAmountMicros": 9990000,
            "currencyCode": "EUR",
            "offerID": "trial7days"
        ])

        let expectation = expectation(description: "purchaseCompleted with trial completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testPurchaseCompleted_withConvertedFromFreeTrial() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "purchaseCompleted", arguments: [
            "event": "convertedFromFreeTrial",
            "countryCode": "UK",
            "productID": "com.app.yearly",
            "purchaseType": "subscription",
            "priceAmountMicros": 49990000,
            "currencyCode": "GBP"
        ])

        let expectation = expectation(description: "purchaseCompleted with conversion completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testPurchaseCompleted_withMissingParameters_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "purchaseCompleted", arguments: [
            "event": "completed",
            "countryCode": "US"
        ])

        let expectation = expectation(description: "purchaseCompleted returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testReferralSent_withDefaults() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "referralSent", arguments: [:])

        let expectation = expectation(description: "referralSent completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testReferralSent_withAllParameters() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "referralSent", arguments: [
            "receiversCount": 3,
            "kind": "email",
            "params": ["campaign": "refer_friend"],
            "customUserID": "user789"
        ])

        let expectation = expectation(description: "referralSent with params completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testUserRatingSubmitted() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "userRatingSubmitted", arguments: [
            "rating": 5,
            "comment": "Great app!",
            "params": ["platform": "macOS"],
            "customUserID": "user123"
        ])

        let expectation = expectation(description: "userRatingSubmitted completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testUserRatingSubmitted_withMissingRating_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "userRatingSubmitted", arguments: [:])

        let expectation = expectation(description: "userRatingSubmitted returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            XCTAssertEqual(error.message, "rating is required")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testErrorOccurred_withMinimalParameters() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "errorOccurred", arguments: [
            "id": "error_001"
        ])

        let expectation = expectation(description: "errorOccurred completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testErrorOccurred_withThrownExceptionCategory() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "errorOccurred", arguments: [
            "id": "error_002",
            "category": "thrownException",
            "message": "Null pointer exception",
            "parameters": ["file": "main.dart"],
            "floatValue": 1.0,
            "customUserID": "user456"
        ])

        let expectation = expectation(description: "errorOccurred with category completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testErrorOccurred_withUserInputCategory() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "errorOccurred", arguments: [
            "id": "error_003",
            "category": "userInput"
        ])

        let expectation = expectation(description: "errorOccurred with userInput completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testErrorOccurred_withAppStateCategory() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "errorOccurred", arguments: [
            "id": "error_004",
            "category": "appState"
        ])

        let expectation = expectation(description: "errorOccurred with appState completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testErrorOccurred_withUnknownCategory() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "errorOccurred", arguments: [
            "id": "error_005",
            "category": "unknownCategory"
        ])

        let expectation = expectation(description: "errorOccurred with unknown category completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testErrorOccurred_withMissingId_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "errorOccurred", arguments: [:])

        let expectation = expectation(description: "errorOccurred returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            XCTAssertEqual(error.message, "id is required")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testStartDurationSignal() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "startDurationSignal", arguments: [
            "signalType": "Task.Duration",
            "parameters": ["taskType": "download"]
        ])

        let expectation = expectation(description: "startDurationSignal completes")
        plugin.handle(call) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testStartDurationSignal_withMissingSignalType_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "startDurationSignal", arguments: [:])

        let expectation = expectation(description: "startDurationSignal returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            XCTAssertEqual(error.message, "Missing required argument signalType")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testStopAndSendDurationSignal() {
        initializeSDK()

        let startCall = FlutterMethodCall(methodName: "startDurationSignal", arguments: [
            "signalType": "Task.Duration",
            "parameters": ["taskType": "upload"]
        ])
        plugin.handle(startCall) { _ in }

        let stopCall = FlutterMethodCall(methodName: "stopAndSendDurationSignal", arguments: [
            "signalType": "Task.Duration",
            "parameters": ["taskType": "upload"]
        ])

        let expectation = expectation(description: "stopAndSendDurationSignal completes")
        plugin.handle(stopCall) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testStopAndSendDurationSignal_withMissingSignalType_returnsError() {
        initializeSDK()

        let call = FlutterMethodCall(methodName: "stopAndSendDurationSignal", arguments: [:])

        let expectation = expectation(description: "stopAndSendDurationSignal returns error")
        plugin.handle(call) { result in
            guard let error = result as? FlutterError else {
                XCTFail("Expected FlutterError")
                return
            }
            XCTAssertEqual(error.code, "INVALID_ARGUMENT")
            XCTAssertEqual(error.message, "Missing required argument signalType")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testUnknownMethod_returnsNotImplemented() {
        let call = FlutterMethodCall(methodName: "unknownMethod", arguments: nil)

        let expectation = expectation(description: "unknown method returns not implemented")
        plugin.handle(call) { result in
            XCTAssertTrue((result as? NSObject) === FlutterMethodNotImplemented)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    private func initializeSDK() {
        let call = FlutterMethodCall(methodName: "start", arguments: [
            "appID": "32CB6574-6732-4238-879F-582FEBEB6536",
            "testMode": true
        ])
        plugin.handle(call) { _ in }
    }
}
