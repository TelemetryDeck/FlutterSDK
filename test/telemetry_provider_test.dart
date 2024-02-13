import 'package:telemetrydecksdk/telemetry_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telemetrydecksdk/versions.dart';

void main() {
  test('appends flutter sdk telemetry attributes', () async {
    final sut = TelemetryProvider();

    final result = await sut.enrich({});
    // assert the keys 'key1' is present in the result
    expect(
        result,
        containsPair(
            'telemetryClientVersion', "Flutter $telemetryClientVersion"));
    expect(result, containsPair('dartVersion', isNotNull));
  });
}
