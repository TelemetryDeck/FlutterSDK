import 'dart:async';

import 'package:telemetrydecksdk/telemetry_manager_configuration.dart';

import 'telemetrydecksdk_platform_interface.dart';

class Telemetrydecksdk {
  Future<String?> getPlatformVersion() {
    return TelemetrydecksdkPlatform.instance.getPlatformVersion();
  }

  static Future<void> initialize(
      TelemetryManagerConfiguration configuration) async {
    await TelemetrydecksdkPlatform.instance.initialize(configuration);
  }

  Future<void> send(String signalType,
      {String? clientUser, Map<String, String>? additionalPayload}) async {
    await TelemetrydecksdkPlatform.instance.send(signalType,
        clientUser: clientUser, additionalPayload: additionalPayload);
  }

  Future<void> generateNewSession() async {
    await TelemetrydecksdkPlatform.instance.generateNewSession();
  }
}
