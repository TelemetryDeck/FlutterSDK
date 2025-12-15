import 'dart:async';

import 'package:telemetrydecksdk/src/error_category.dart';
import 'package:telemetrydecksdk/src/purchase_event.dart';
import 'package:telemetrydecksdk/src/purchase_type.dart';
import 'package:telemetrydecksdk/src/telemetry_manager_configuration.dart';
import 'package:telemetrydecksdk/src/telemetry_provider.dart';

import 'telemetrydecksdk_platform_interface.dart';

abstract class Telemetrydecksdk {
  const Telemetrydecksdk._();

  static const _telemetryProvider = TelemetryProvider();

  static Future<void> start(TelemetryManagerConfiguration configuration) async {
    final enrichedDefaultParameters = await _telemetryProvider.enrich(
      configuration.defaultParameters,
    );
    final stringifiedeParams = enrichedDefaultParameters.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    final enrichedConfiguration = configuration.copyWith(
      defaultParameters: stringifiedeParams,
    );
    await TelemetrydecksdkPlatform.instance.start(enrichedConfiguration);
  }

  static Future<void> stop() async {
    await TelemetrydecksdkPlatform.instance.stop();
  }

  static Future<void> send(
    String signalType, {
    String? clientUser,
    Map<String, dynamic>? additionalPayload,
    double? floatValue,
  }) async {
    final payload = additionalPayload ?? {};

    final stringifiedPayload = payload.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    await TelemetrydecksdkPlatform.instance.send(
      signalType,
      clientUser: clientUser,
      additionalPayload: stringifiedPayload,
      floatValue: floatValue,
    );
  }

  static Future<void> startDurationSignal(
    String signalType, {
    Map<String, String>? parameters,
  }) async {
    final payload = parameters ?? {};

    final stringifiedPayload = payload.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    await TelemetrydecksdkPlatform.instance.startDurationSignal(
      signalType,
      parameters: stringifiedPayload,
    );
  }

  static Future<void> stopAndSendDurationSignal(
    String signalType, {
    Map<String, String>? parameters,
  }) async {
    final payload = parameters ?? {};

    final stringifiedPayload = payload.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    await TelemetrydecksdkPlatform.instance.stopAndSendDurationSignal(
      signalType,
      parameters: stringifiedPayload,
    );
  }

  static Future<void> generateNewSession() async {
    await TelemetrydecksdkPlatform.instance.generateNewSession();
  }

  static Future<void> updateDefaultUser(String clientUser) async {
    await TelemetrydecksdkPlatform.instance.updateDefaultUser(clientUser);
  }

  static Future<void> navigate(String sourcePath, String destinationPath,
      {String? clientUser}) async {
    await TelemetrydecksdkPlatform.instance
        .navigate(sourcePath, destinationPath, clientUser: clientUser);
  }

  static Future<void> navigateToDestination(String destinationPath,
      {String? clientUser}) async {
    await TelemetrydecksdkPlatform.instance
        .navigateToDestination(destinationPath, clientUser: clientUser);
  }

  static Future<void> acquiredUser(String channel,
      {Map<String, String>? params, String? customUserID}) async {
    await TelemetrydecksdkPlatform.instance
        .acquiredUser(channel, params: params, customUserID: customUserID);
  }

  static Future<void> leadStarted(String leadId,
      {Map<String, String>? params, String? customUserID}) async {
    await TelemetrydecksdkPlatform.instance
        .leadStarted(leadId, params: params, customUserID: customUserID);
  }

  static Future<void> leadConverted(String leadId,
      {Map<String, String>? params, String? customUserID}) async {
    await TelemetrydecksdkPlatform.instance
        .leadConverted(leadId, params: params, customUserID: customUserID);
  }

  static Future<void> onboardingCompleted(
      {Map<String, String>? params, String? customUserID}) async {
    await TelemetrydecksdkPlatform.instance
        .onboardingCompleted(params: params, customUserID: customUserID);
  }

  static Future<void> coreFeatureUsed(String featureName,
      {Map<String, String>? params, String? customUserID}) async {
    await TelemetrydecksdkPlatform.instance.coreFeatureUsed(featureName,
        params: params, customUserID: customUserID);
  }

  static Future<void> paywallShown(String reason,
      {Map<String, String>? params, String? customUserID}) async {
    await TelemetrydecksdkPlatform.instance
        .paywallShown(reason, params: params, customUserID: customUserID);
  }

  static Future<void> purchaseCompleted(
      PurchaseEvent event,
      String countryCode,
      String productID,
      PurchaseType purchaseType,
      int priceAmountMicros,
      String currencyCode,
      {String? offerID,
      Map<String, String>? params,
      String? customUserID}) async {
    await TelemetrydecksdkPlatform.instance.purchaseCompleted(
        event.name,
        countryCode,
        productID,
        purchaseType.name,
        priceAmountMicros,
        currencyCode,
        offerID: offerID,
        params: params,
        customUserID: customUserID);
  }

  static Future<void> referralSent(
      {int receiversCount = 1,
      String? kind,
      Map<String, String>? params,
      String? customUserID}) async {
    await TelemetrydecksdkPlatform.instance.referralSent(
        receiversCount: receiversCount,
        kind: kind,
        params: params,
        customUserID: customUserID);
  }

  static Future<void> userRatingSubmitted(int rating,
      {String? comment,
      Map<String, String>? params,
      String? customUserID}) async {
    await TelemetrydecksdkPlatform.instance.userRatingSubmitted(rating,
        comment: comment, params: params, customUserID: customUserID);
  }

  static Future<void> errorOccurred(String id,
      {ErrorCategory? category,
      String? message,
      Map<String, String>? parameters,
      double? floatValue,
      String? customUserID}) async {
    await TelemetrydecksdkPlatform.instance.errorOccurred(id,
        category: category?.name,
        message: message,
        parameters: parameters,
        floatValue: floatValue,
        customUserID: customUserID);
  }
}
