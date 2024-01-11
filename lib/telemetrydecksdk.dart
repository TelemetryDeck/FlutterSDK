import 'dart:async';
import 'dart:io';

import 'package:telemetrydecksdk/telemetry_manager_configuration.dart';

import 'telemetrydecksdk_platform_interface.dart';

class Telemetrydecksdk {
  Future<String?> getPlatformVersion() {
    return TelemetrydecksdkPlatform.instance.getPlatformVersion();
  }

  String getDartVersion() {
    final version = Platform.version;
    return version;
  }

  static Future<void> initialize(
      TelemetryManagerConfiguration configuration) async {
    await TelemetrydecksdkPlatform.instance.initialize(configuration);
  }

  Future<void> send(String signalType,
      {String? clientUser, Map<String, String>? additionalPayload}) async {
    var payload = await appendFlutterAttributes(additionalPayload);
    await TelemetrydecksdkPlatform.instance
        .send(signalType, clientUser: clientUser, additionalPayload: payload);
  }

  Future<void> generateNewSession() async {
    await TelemetrydecksdkPlatform.instance.generateNewSession();
  }

  Future<Map<String, String>> appendFlutterAttributes(
      Map<String, String>? payload) async {
    Map<String, String> result = payload ?? {};
    result['dartVersion'] = getDartVersion();
    return result;
  }
}
