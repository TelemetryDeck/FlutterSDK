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
  }) async {
    await methodChannel.invokeMethod<void>(
      'send',
      {
        'signalType': signalType,
        'clientUser': clientUser,
        'additionalPayload': additionalPayload,
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
}
