import 'package:flutter_test/flutter_test.dart';
import 'package:telemetrydecksdk/src/telemetry_provider.dart';
import 'package:telemetrydecksdk/src/versions.dart';

void main() {
  test('appends flutter sdk telemetry attributes', () async {
    const sut = TelemetryProvider();

    final result = await sut.enrich({});
    // assert the keys 'key1' is present in the result
    expect(
      result,
      containsPair('TelemetryDeck.SDK.version', telemetryClientVersion),
    );
    expect(
      result,
      containsPair('TelemetryDeck.SDK.name', 'Flutter SDK'),
    );
    expect(result, containsPair('TelemetryDeck.SDK.dartVersion', isNotNull));
  });
}
