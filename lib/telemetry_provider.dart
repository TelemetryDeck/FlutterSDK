import 'package:telemetrydecksdk/version_reader.dart';
import 'package:telemetrydecksdk/versions.dart';

class TelemetryProvider {
  final versionReader = DartVersionReader();

  /// Adds Flutter specific payload attributes to outgoing signals before passing them to the native platform API.
  /// This method will overwrite the default `telemetryClientVersion`.
  Future<Map<String, String>> enrich(Map<String, String>? payload) async {
    Map<String, String> result = payload ?? {};
    result['telemetryClientVersion'] = "Flutter $telemetryClientVersion";
    result['dartVersion'] = versionReader.readVersion();
    return result;
  }
}
