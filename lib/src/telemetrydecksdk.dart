import 'dart:async';

import 'package:telemetrydecksdk/src/telemetry_manager_configuration.dart';
import 'package:telemetrydecksdk/src/telemetry_provider.dart';

import 'telemetrydecksdk_platform_interface.dart';

abstract class Telemetrydecksdk {
  const Telemetrydecksdk._();

  static const _telemetryProvider = TelemetryProvider();

  static Future<void> start(TelemetryManagerConfiguration configuration) async {
    await TelemetrydecksdkPlatform.instance.start(configuration);
  }

  static Future<void> stop() async {
    await TelemetrydecksdkPlatform.instance.stop();
  }

  static Future<void> send(
    String signalType, {
    String? clientUser,
    Map<String, dynamic>? additionalPayload,
  }) async {
    final payload = await _telemetryProvider.enrich(additionalPayload);

    final stringifiedPayload = payload.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    await TelemetrydecksdkPlatform.instance.send(
      signalType,
      clientUser: clientUser,
      additionalPayload: stringifiedPayload,
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
}
