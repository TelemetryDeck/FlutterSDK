class TelemetryManagerConfiguration {
  /// Your app's ID for Telemetry.
  String appID;

  /// The Telemetrydeck domain to send signals to.
  String? apiBaseURL;

  /// Instead of specifying a user identifier with each `send` call, you can set your user's name/email/identifier here.
  /// The `defaultUser` value will be sent with every signal.
  ///
  /// Note that just as with specifying the user identifier with the `send` call, the identifier will never leave the device.
  /// Instead it is used to create a hash, which is included in your signal to allow you to count distinct users.
  String? defaultUser;

  /// Log the current status to the signal cache to the console.
  bool? debug;

  /// If `true` any signals sent will be marked as *Testing* signals.
  bool? testMode;

  TelemetryManagerConfiguration({
    required this.appID,
    this.apiBaseURL,
    this.defaultUser,
    this.debug,
    this.testMode,
  });

  /// to map
  Map<String, dynamic> toMap() {
    return {
      'appID': appID,
      'apiBaseURL': apiBaseURL,
      'defaultUser': defaultUser,
      'debug': debug,
      'testMode': testMode,
    };
  }
}
