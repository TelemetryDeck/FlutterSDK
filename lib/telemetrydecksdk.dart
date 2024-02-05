import 'dart:async';
import 'dart:io';

import 'package:telemetrydecksdk/versions.dart';
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

  static Future<void> start(TelemetryManagerConfiguration configuration) async {
    await TelemetrydecksdkPlatform.instance.start(configuration);
  }

  static Future<void> stop() async {
    await TelemetrydecksdkPlatform.instance.stop();
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

  Future<void> updateDefaultUser(String clientUser) async {
    await TelemetrydecksdkPlatform.instance.updateDefaultUser(clientUser);
  }

  Future<Map<String, String>> appendFlutterAttributes(
      Map<String, String>? payload) async {
    Map<String, String> result = payload ?? {};
    result['telemetryClientVersion'] = "Flutter $telemetryClientVersion";
    result['dartVersion'] = getDartVersion();
    return result;
  }
}
