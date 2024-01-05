
import 'telemetrydecksdk_platform_interface.dart';

class Telemetrydecksdk {
  Future<String?> getPlatformVersion() {
    return TelemetrydecksdkPlatform.instance.getPlatformVersion();
  }
}
