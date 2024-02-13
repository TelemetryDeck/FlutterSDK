# TelemetryDeck SDK for Flutter

This package allows your app to send signals to [TelemetryDeck](https://telemetrydeck.com/) using the native TelemetryDeck libraries for [Kotlin](https://github.com/TelemetryDeck/KotlinSDK) and [iOS](https://github.com/TelemetryDeck/SwiftClient).

## Getting started

- Obtain your TelemetryDeck App ID from the [Dashboard](https://dashboard.telemetrydeck.com/)

- Follow the installing instructions on [pub.dev](https://pub.dev/packages/telemetrydecksdk/install).

- Initialize the TelemetryClient:

```dart
void main() {
  // ensure the platform channels are available
  WidgetsFlutterBinding.ensureInitialized();
  // configure and start the TelemetryClient
  Telemetrydecksdk.start(TelemetryManagerConfiguration(
      appID: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"));
  runApp(const MyApp());
}
```

## Permission for internet access

Sending signals requires access to the internet so the following permission should be added to the app's `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Sending signals

Send a signal using the following method:

```dart
TelemetryManager.send("signal_type")
```

## Signals with additional attributes

Append any number of custom attributes to a signal:

```dart
TelemetryManager.send("signal_type",
  additionalPayload: {"attributeName": "value"});
}
```

## Stop sending signals

Prevent signals from being sent using the stop method:

```dart
TelemetryManager.stop()
```

In order to restart sending events, you will need to call the `start` method again.

## Test mode

If your app's build configuration is set to "Debug", all signals sent will be marked as testing signals. In the Telemetry Viewer app, activate **Test Mode** to see those.

If you want to manually control whether test mode is active, you can set the `testMode` field:

```swift
Telemetrydecksdk.start(TelemetryManagerConfiguration(
  appID: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
  testMode: true));
```

## Custom Server

A very small subset of our customers will want to use a custom signal ingestion server or a custom proxy server. To do so, you can pass the URL of the custom server to the `TelemetryManagerConfiguration`:

```swift
Telemetrydecksdk.start(TelemetryManagerConfiguration(
  appID: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
  apiBaseURL: "https://nom.telemetrydeck.com"));
```

## Logging output

By default, some logs helpful for monitoring TelemetryDeck are printed out to the console. You can enable additional logs by setting the `debug` field to `true`:

```dart
void main() {
  Telemetrydecksdk.start(TelemetryManagerConfiguration(
      appID: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
      debug: true));
}
```
