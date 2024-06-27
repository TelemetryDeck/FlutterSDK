import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:telemetrydecksdk/src/telemetry_manager_configuration.dart';

import 'telemetrydecksdk_method_channel.dart';

abstract class TelemetrydecksdkPlatform extends PlatformInterface {
  /// Constructs a TelemetrydecksdkPlatform.
  TelemetrydecksdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static TelemetrydecksdkPlatform _instance = MethodChannelTelemetrydecksdk();

  /// The default instance of [TelemetrydecksdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelTelemetrydecksdk].
  static TelemetrydecksdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TelemetrydecksdkPlatform] when
  /// they register themselves.
  static set instance(TelemetrydecksdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> start(TelemetryManagerConfiguration configuration) {
    throw UnimplementedError('start() has not been implemented.');
  }

  Future<void> stop() {
    throw UnimplementedError('stop() has not been implemented.');
  }

  Future<void> send(
    String signalType, {
    String? clientUser,
    Map<String, String>? additionalPayload,
  }) async {
    throw UnimplementedError('send() has not been implemented.');
  }

  Future<void> generateNewSession() async {
    throw UnimplementedError('generateNewSession() has not been implemented.');
  }

  Future<void> updateDefaultUser(String clientUser) async {
    throw UnimplementedError('updateDefaultUser() has not been implemented.');
  }

  Future<void> navigate(String sourcePath, String destinationPath,
      {String? clientUser}) async {
    throw UnimplementedError('navigate() has not been implemented.');
  }

  Future<void> navigateToDestination(String destinationPath,
      {String? clientUser}) async {
    throw UnimplementedError(
        'navigateToDestination() has not been implemented.');
  }
}
