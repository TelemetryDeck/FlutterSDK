import 'dart:io';

class DartVersionReader {
  const DartVersionReader();

  String readVersion() {
    final version = Platform.version;

    return version.replaceAll("\"", "'");
  }
}
