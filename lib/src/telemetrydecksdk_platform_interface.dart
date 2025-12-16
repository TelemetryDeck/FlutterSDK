import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:telemetrydecksdk/src/telemetry_manager_configuration.dart';

import 'telemetrydecksdk_method_channel.dart';

abstract class TelemetrydecksdkPlatform extends PlatformInterface {
  /// Constructs a TelemetrydecksdkPlatform.
  TelemetrydecksdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static TelemetrydecksdkPlatform _instance = MethodChannelTelemetrydecksdk();

  /// The default instance of [TelemetrydecksdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelTelemetrydecksdk].
  static TelemetrydecksdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TelemetrydecksdkPlatform] when
  /// they register themselves.
  static set instance(TelemetrydecksdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> start(TelemetryManagerConfiguration configuration) {
    throw UnimplementedError('start() has not been implemented.');
  }

  Future<void> stop() {
    throw UnimplementedError('stop() has not been implemented.');
  }

  Future<void> send(
    String signalType, {
    String? clientUser,
    Map<String, String>? additionalPayload,
    double? floatValue,
  }) async {
    throw UnimplementedError('send() has not been implemented.');
  }

  Future<void> startDurationSignal(
    String signalType, {
    Map<String, String>? parameters,
  }) async {
    throw UnimplementedError('startDurationSignal() has not been implemented.');
  }

  Future<void> stopAndSendDurationSignal(
    String signalType, {
    Map<String, String>? parameters,
  }) async {
    throw UnimplementedError(
        'stopAndSendDurationSignal() has not been implemented.');
  }

  Future<void> generateNewSession() async {
    throw UnimplementedError('generateNewSession() has not been implemented.');
  }

  Future<void> updateDefaultUser(String clientUser) async {
    throw UnimplementedError('updateDefaultUser() has not been implemented.');
  }

  Future<void> navigate(String sourcePath, String destinationPath,
      {String? clientUser}) async {
    throw UnimplementedError('navigate() has not been implemented.');
  }

  Future<void> navigateToDestination(String destinationPath,
      {String? clientUser}) async {
    throw UnimplementedError(
        'navigateToDestination() has not been implemented.');
  }

  Future<void> acquiredUser(String channel,
      {Map<String, String>? params, String? customUserID}) async {
    throw UnimplementedError('acquiredUser() has not been implemented.');
  }

  Future<void> leadStarted(String leadId,
      {Map<String, String>? params, String? customUserID}) async {
    throw UnimplementedError('leadStarted() has not been implemented.');
  }

  Future<void> leadConverted(String leadId,
      {Map<String, String>? params, String? customUserID}) async {
    throw UnimplementedError('leadConverted() has not been implemented.');
  }

  Future<void> onboardingCompleted(
      {Map<String, String>? params, String? customUserID}) async {
    throw UnimplementedError('onboardingCompleted() has not been implemented.');
  }

  Future<void> coreFeatureUsed(String featureName,
      {Map<String, String>? params, String? customUserID}) async {
    throw UnimplementedError('coreFeatureUsed() has not been implemented.');
  }

  Future<void> paywallShown(String reason,
      {Map<String, String>? params, String? customUserID}) async {
    throw UnimplementedError('paywallShown() has not been implemented.');
  }

  Future<void> purchaseCompleted(
      String event,
      String countryCode,
      String productID,
      String purchaseType,
      int priceAmountMicros,
      String currencyCode,
      {String? offerID,
      Map<String, String>? params,
      String? customUserID}) async {
    throw UnimplementedError('purchaseCompleted() has not been implemented.');
  }

  Future<void> referralSent(
      {int receiversCount = 1,
      String? kind,
      Map<String, String>? params,
      String? customUserID}) async {
    throw UnimplementedError('referralSent() has not been implemented.');
  }

  Future<void> userRatingSubmitted(int rating,
      {String? comment,
      Map<String, String>? params,
      String? customUserID}) async {
    throw UnimplementedError('userRatingSubmitted() has not been implemented.');
  }

  Future<void> errorOccurred(String id,
      {String? category,
      String? message,
      Map<String, String>? parameters,
      double? floatValue,
      String? customUserID}) async {
    throw UnimplementedError('errorOccurred() has not been implemented.');
  }
}
