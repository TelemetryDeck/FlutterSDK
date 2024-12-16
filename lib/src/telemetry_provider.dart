import 'package:telemetrydecksdk/src/dart_version_reader.dart';
import 'package:telemetrydecksdk/src/versions.dart';

class TelemetryProvider {
  final DartVersionReader versionReader;

  const TelemetryProvider({
    this.versionReader = const DartVersionReader(),
  });

  /// Adds Flutter specific payload attributes to outgoing signals before passing them to the native platform API.
  /// This method will overwrite the default `telemetryClientVersion`.
  Future<Map<String, dynamic>> enrich(Map<String, dynamic>? payload) async {
    Map<String, dynamic> result = payload ?? {};
    result['TelemetryDeck.SDK.name'] = "Flutter SDK";
    result['TelemetryDeck.SDK.version'] = telemetryClientVersion;
    result['TelemetryDeck.SDK.nameAndVersion'] =
        "Flutter SDK $telemetryClientVersion";
    result['TelemetryDeck.SDK.dartVersion'] = versionReader.readVersion();

    return result;
  }
}
