import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

Future<String> getTelemetryClientVersion() async {
  String yamlString = await rootBundle.loadString('assets/versions.yaml');
  var doc = loadYaml(yamlString);
  return doc["telemetryClientVersion"];
}
