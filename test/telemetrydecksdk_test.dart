import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telemetrydecksdk/src/telemetrydecksdk_method_channel.dart';
import 'package:telemetrydecksdk/src/telemetrydecksdk_platform_interface.dart';
import 'package:telemetrydecksdk/src/versions.dart';
import 'package:telemetrydecksdk/telemetrydecksdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('telemetrydecksdk');
  final calls = <MethodCall>[];

  void replyWith(Future<Object?> Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          calls.add(call);
          return handler(call);
        });
  }

  setUp(() {
    calls.clear();
    replyWith((_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('$MethodChannelTelemetrydecksdk is the default instance', () {
    expect(
      TelemetrydecksdkPlatform.instance,
      isInstanceOf<MethodChannelTelemetrydecksdk>(),
    );
  });

  test(
    'start adds the Flutter SDK metadata to the default parameters',
    () async {
      await Telemetrydecksdk.start(
        const TelemetryManagerConfiguration(
          appID: "XXXX-XXXX-XXXXX",
          namespace: "my-namespace",
          defaultParameters: {"appParameter": "appValue"},
        ),
      );

      final arguments = calls.single.arguments as Map;
      expect(calls.single.method, 'start');
      expect(arguments['appID'], "XXXX-XXXX-XXXXX");
      expect(arguments['namespace'], "my-namespace");
      expect(
        arguments['defaultParameters'],
        allOf(
          containsPair('appParameter', 'appValue'),
          containsPair('TelemetryDeck.SDK.version', telemetryClientVersion),
          containsPair('TelemetryDeck.SDK.name', 'Flutter SDK'),
        ),
      );
    },
  );

  test('send passes payload values as strings', () async {
    await Telemetrydecksdk.send(
      "Test.signal",
      clientUser: "user",
      additionalPayload: {"count": 3, "flag": true},
      floatValue: 1.5,
    );

    expect(calls.single.method, 'send');
    expect(calls.single.arguments, {
      'signalType': "Test.signal",
      'clientUser': "user",
      'additionalPayload': {"count": "3", "flag": "true"},
      'floatValue': 1.5,
    });
  });

  test('native errors complete the Future with a PlatformException', () async {
    replyWith(
      (_) async =>
          throw PlatformException(code: 'TELEMETRY_ERROR', message: 'failed'),
    );

    await expectLater(
      Telemetrydecksdk.send("Test.signal"),
      throwsA(
        isA<PlatformException>().having(
          (e) => e.code,
          'code',
          'TELEMETRY_ERROR',
        ),
      ),
    );
  });
}
