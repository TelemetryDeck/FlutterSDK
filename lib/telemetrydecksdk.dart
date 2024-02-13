import 'dart:async';

import 'package:telemetrydecksdk/telemetry_provider.dart';
import 'package:telemetrydecksdk/telemetry_manager_configuration.dart';

import 'telemetrydecksdk_platform_interface.dart';

class Telemetrydecksdk {
  final telemetryProvider = TelemetryProvider();

  static Future<void> start(TelemetryManagerConfiguration configuration) async {
    await TelemetrydecksdkPlatform.instance.start(configuration);
  }

  static Future<void> stop() async {
    await TelemetrydecksdkPlatform.instance.stop();
  }

  Future<void> send(String signalType,
      {String? clientUser, Map<String, String>? additionalPayload}) async {
    var payload = await telemetryProvider.enrich(additionalPayload);
    await TelemetrydecksdkPlatform.instance
        .send(signalType, clientUser: clientUser, additionalPayload: payload);
  }

  Future<void> generateNewSession() async {
    await TelemetrydecksdkPlatform.instance.generateNewSession();
  }

  Future<void> updateDefaultUser(String clientUser) async {
    await TelemetrydecksdkPlatform.instance.updateDefaultUser(clientUser);
  }
}
