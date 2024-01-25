import 'package:flutter_test/flutter_test.dart';
import 'package:telemetrydecksdk/telemetry_manager_configuration.dart';
import 'package:telemetrydecksdk/telemetrydecksdk.dart';
import 'package:telemetrydecksdk/telemetrydecksdk_platform_interface.dart';
import 'package:telemetrydecksdk/telemetrydecksdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTelemetrydecksdkPlatform
    with MockPlatformInterfaceMixin
    implements TelemetrydecksdkPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> start(TelemetryManagerConfiguration configuration) =>
      Future.value();

  @override
  Future<void> generateNewSession() async => ();

  @override
  Future<void> updateDefaultUser(String clientUser) async => ();

  @override
  Future<void> send(String signalType,
          {String? clientUser, Map<String, String>? additionalPayload}) async =>
      ();
}

void main() {
  final TelemetrydecksdkPlatform initialPlatform =
      TelemetrydecksdkPlatform.instance;

  test('$MethodChannelTelemetrydecksdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTelemetrydecksdk>());
  });

  test('getPlatformVersion', () async {
    Telemetrydecksdk telemetrydecksdkPlugin = Telemetrydecksdk();
    MockTelemetrydecksdkPlatform fakePlatform = MockTelemetrydecksdkPlatform();
    TelemetrydecksdkPlatform.instance = fakePlatform;

    expect(await telemetrydecksdkPlugin.getPlatformVersion(), '42');
  });

  test('initialize', () async {
    MockTelemetrydecksdkPlatform fakePlatform = MockTelemetrydecksdkPlatform();
    TelemetrydecksdkPlatform.instance = fakePlatform;
    var configuration = TelemetryManagerConfiguration(appID: "XXXX-XXXX-XXXXX");

    // if no exception occures the test will pass
    await Telemetrydecksdk.start(configuration);
  });
}
