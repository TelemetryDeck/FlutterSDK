import 'dart:io';

class DartVersionReader {
  String readVersion() {
    final version = Platform.version;
    return version.replaceAll("\"", "'");
  }
}
