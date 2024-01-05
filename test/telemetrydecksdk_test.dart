import 'package:flutter_test/flutter_test.dart';
import 'package:telemetrydecksdk/telemetrydecksdk.dart';
import 'package:telemetrydecksdk/telemetrydecksdk_platform_interface.dart';
import 'package:telemetrydecksdk/telemetrydecksdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTelemetrydecksdkPlatform
    with MockPlatformInterfaceMixin
    implements TelemetrydecksdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TelemetrydecksdkPlatform initialPlatform = TelemetrydecksdkPlatform.instance;

  test('$MethodChannelTelemetrydecksdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTelemetrydecksdk>());
  });

  test('getPlatformVersion', () async {
    Telemetrydecksdk telemetrydecksdkPlugin = Telemetrydecksdk();
    MockTelemetrydecksdkPlatform fakePlatform = MockTelemetrydecksdkPlatform();
    TelemetrydecksdkPlatform.instance = fakePlatform;

    expect(await telemetrydecksdkPlugin.getPlatformVersion(), '42');
  });
}
