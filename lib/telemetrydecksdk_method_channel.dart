import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:telemetrydecksdk/telemetry_manager_configuration.dart';

import 'telemetrydecksdk_platform_interface.dart';

/// An implementation of [TelemetrydecksdkPlatform] that uses method channels.
class MethodChannelTelemetrydecksdk extends TelemetrydecksdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('telemetrydecksdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> initialize(TelemetryManagerConfiguration configuration) async {
    await methodChannel.invokeMethod<void>('initialize', configuration.toMap());
  }

  @override
  Future<void> send(String signalType,
      {String? clientUser, Map<String, String>? additionalPayload}) async {
    await methodChannel.invokeMethod<void>('send', {
      'signalType': signalType,
      'clientUser': clientUser,
      'additionalPayload': additionalPayload
    });
  }

  @override
  Future<void> generateNewSession() async {
    await methodChannel.invokeMethod<void>('generateNewSession');
  }

  @override
  Future<void> updateDefaultUser(String clientUser) async {
    await methodChannel.invokeMethod<void>('updateDefaultUser', clientUser);
  }
}
