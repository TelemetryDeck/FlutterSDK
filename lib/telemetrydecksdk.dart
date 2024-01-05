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
}
