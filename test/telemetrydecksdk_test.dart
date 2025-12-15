import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:telemetrydecksdk/src/telemetrydecksdk_method_channel.dart';
import 'package:telemetrydecksdk/src/telemetrydecksdk_platform_interface.dart';
import 'package:telemetrydecksdk/telemetrydecksdk.dart';

class MockTelemetrydecksdkPlatform
    with MockPlatformInterfaceMixin
    implements TelemetrydecksdkPlatform {
  @override
  Future<void> start(TelemetryManagerConfiguration configuration) =>
      Future.value();

  @override
  Future<void> stop() async => ();

  @override
  Future<void> generateNewSession() async => ();

  @override
  Future<void> updateDefaultUser(String clientUser) async => ();

  @override
  Future<void> send(
    String signalType, {
    String? clientUser,
    Map<String, String>? additionalPayload,
    double? floatValue,
  }) async =>
      ();

  @override
  Future<void> startDurationSignal(String signalType,
          {Map<String, String>? parameters}) async =>
      ();

  @override
  Future<void> stopAndSendDurationSignal(String signalType,
          {Map<String, String>? parameters}) async =>
      ();

  @override
  Future<void> navigate(String sourcePath, String destinationPath,
          {String? clientUser}) async =>
      ();

  @override
  Future<void> navigateToDestination(String destinationPath,
          {String? clientUser}) async =>
      ();

  @override
  Future<void> acquiredUser(String channel,
          {Map<String, String>? params, String? customUserID}) async =>
      ();

  @override
  Future<void> leadStarted(String leadId,
          {Map<String, String>? params, String? customUserID}) async =>
      ();

  @override
  Future<void> leadConverted(String leadId,
          {Map<String, String>? params, String? customUserID}) async =>
      ();

  @override
  Future<void> onboardingCompleted(
          {Map<String, String>? params, String? customUserID}) async =>
      ();

  @override
  Future<void> coreFeatureUsed(String featureName,
          {Map<String, String>? params, String? customUserID}) async =>
      ();

  @override
  Future<void> paywallShown(String reason,
          {Map<String, String>? params, String? customUserID}) async =>
      ();

  @override
  Future<void> purchaseCompleted(
          String event,
          String countryCode,
          String productID,
          String purchaseType,
          int priceAmountMicros,
          String currencyCode,
          {String? offerID,
          Map<String, String>? params,
          String? customUserID}) async =>
      ();

  @override
  Future<void> referralSent(
          {int receiversCount = 1,
          String? kind,
          Map<String, String>? params,
          String? customUserID}) async =>
      ();

  @override
  Future<void> userRatingSubmitted(int rating,
          {String? comment,
          Map<String, String>? params,
          String? customUserID}) async =>
      ();

  @override
  Future<void> errorOccurred(String id,
          {String? category,
          String? message,
          Map<String, String>? parameters,
          double? floatValue,
          String? customUserID}) async =>
      ();
}

void main() {
  final TelemetrydecksdkPlatform initialPlatform =
      TelemetrydecksdkPlatform.instance;

  test('$MethodChannelTelemetrydecksdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTelemetrydecksdk>());
  });

  test('initialize', () async {
    MockTelemetrydecksdkPlatform fakePlatform = MockTelemetrydecksdkPlatform();
    TelemetrydecksdkPlatform.instance = fakePlatform;

    const configuration = TelemetryManagerConfiguration(
      appID: "XXXX-XXXX-XXXXX",
    );

    // if no exception occures the test will pass
    await Telemetrydecksdk.start(configuration);
  });
}
