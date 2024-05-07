import 'package:flutter_test/flutter_test.dart';
import 'package:telemetrydecksdk/src/dart_version_reader.dart';

void main() {
  test('returns dart version without double quotes', () async {
    const sut = DartVersionReader();

    expect(sut.readVersion(), isNot(contains('"')));
  });
}
