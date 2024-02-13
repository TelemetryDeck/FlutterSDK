import 'package:telemetrydecksdk/version_reader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns dart version without double quotes', () async {
    final sut = DartVersionReader();

    expect(sut.readVersion(), isNot(contains('"')));
  });
}
