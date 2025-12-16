import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:telemetrydecksdk/src/telemetry_manager_configuration.dart';

import 'telemetrydecksdk_platform_interface.dart';

/// An implementation of [TelemetrydecksdkPlatform] that uses method channels.
class MethodChannelTelemetrydecksdk extends TelemetrydecksdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('telemetrydecksdk');

  @override
  Future<void> start(TelemetryManagerConfiguration configuration) async {
    await methodChannel.invokeMethod<void>('start', configuration.toMap());
  }

  @override
  Future<void> stop() async {
    await methodChannel.invokeMethod<void>('stop');
  }

  @override
  Future<void> send(
    String signalType, {
    String? clientUser,
    Map<String, String>? additionalPayload,
    double? floatValue,
  }) async {
    await methodChannel.invokeMethod<void>(
      'send',
      {
        'signalType': signalType,
        'clientUser': clientUser,
        'additionalPayload': additionalPayload,
        'floatValue': floatValue,
      },
    );
  }

  @override
  Future<void> startDurationSignal(
    String signalType, {
    Map<String, String>? parameters,
  }) async {
    await methodChannel.invokeMethod<void>(
      'startDurationSignal',
      {
        'signalType': signalType,
        'parameters': parameters,
      },
    );
  }

  @override
  Future<void> stopAndSendDurationSignal(
    String signalType, {
    Map<String, String>? parameters,
  }) async {
    await methodChannel.invokeMethod<void>(
      'stopAndSendDurationSignal',
      {
        'signalType': signalType,
        'parameters': parameters,
      },
    );
  }

  @override
  Future<void> generateNewSession() async {
    await methodChannel.invokeMethod<void>('generateNewSession');
  }

  @override
  Future<void> updateDefaultUser(String clientUser) async {
    await methodChannel.invokeMethod<void>('updateDefaultUser', clientUser);
  }

  @override
  Future<void> navigate(String sourcePath, String destinationPath,
      {String? clientUser}) async {
    await methodChannel.invokeMethod<void>('navigate', {
      'sourcePath': sourcePath,
      'destinationPath': destinationPath,
      'clientUser': clientUser,
    });
  }

  @override
  Future<void> navigateToDestination(String destinationPath,
      {String? clientUser}) async {
    await methodChannel.invokeMethod<void>('navigateToDestination', {
      'destinationPath': destinationPath,
      'clientUser': clientUser,
    });
  }

  @override
  Future<void> acquiredUser(String channel,
      {Map<String, String>? params, String? customUserID}) async {
    await methodChannel.invokeMethod<void>('acquiredUser', {
      'channel': channel,
      'params': params,
      'customUserID': customUserID,
    });
  }

  @override
  Future<void> leadStarted(String leadId,
      {Map<String, String>? params, String? customUserID}) async {
    await methodChannel.invokeMethod<void>('leadStarted', {
      'leadId': leadId,
      'params': params,
      'customUserID': customUserID,
    });
  }

  @override
  Future<void> leadConverted(String leadId,
      {Map<String, String>? params, String? customUserID}) async {
    await methodChannel.invokeMethod<void>('leadConverted', {
      'leadId': leadId,
      'params': params,
      'customUserID': customUserID,
    });
  }

  @override
  Future<void> onboardingCompleted(
      {Map<String, String>? params, String? customUserID}) async {
    await methodChannel.invokeMethod<void>('onboardingCompleted', {
      'params': params,
      'customUserID': customUserID,
    });
  }

  @override
  Future<void> coreFeatureUsed(String featureName,
      {Map<String, String>? params, String? customUserID}) async {
    await methodChannel.invokeMethod<void>('coreFeatureUsed', {
      'featureName': featureName,
      'params': params,
      'customUserID': customUserID,
    });
  }

  @override
  Future<void> paywallShown(String reason,
      {Map<String, String>? params, String? customUserID}) async {
    await methodChannel.invokeMethod<void>('paywallShown', {
      'reason': reason,
      'params': params,
      'customUserID': customUserID,
    });
  }

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
      String? customUserID}) async {
    await methodChannel.invokeMethod<void>('purchaseCompleted', {
      'event': event,
      'countryCode': countryCode,
      'productID': productID,
      'purchaseType': purchaseType,
      'priceAmountMicros': priceAmountMicros,
      'currencyCode': currencyCode,
      'offerID': offerID,
      'params': params,
      'customUserID': customUserID,
    });
  }

  @override
  Future<void> referralSent(
      {int receiversCount = 1,
      String? kind,
      Map<String, String>? params,
      String? customUserID}) async {
    await methodChannel.invokeMethod<void>('referralSent', {
      'receiversCount': receiversCount,
      'kind': kind,
      'params': params,
      'customUserID': customUserID,
    });
  }

  @override
  Future<void> userRatingSubmitted(int rating,
      {String? comment,
      Map<String, String>? params,
      String? customUserID}) async {
    await methodChannel.invokeMethod<void>('userRatingSubmitted', {
      'rating': rating,
      'comment': comment,
      'params': params,
      'customUserID': customUserID,
    });
  }

  @override
  Future<void> errorOccurred(String id,
      {String? category,
      String? message,
      Map<String, String>? parameters,
      double? floatValue,
      String? customUserID}) async {
    await methodChannel.invokeMethod<void>('errorOccurred', {
      'id': id,
      'category': category,
      'message': message,
      'parameters': parameters,
      'floatValue': floatValue,
      'customUserID': customUserID,
    });
  }
}
