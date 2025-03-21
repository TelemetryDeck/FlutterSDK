# TelemetryDeck SDK for Flutter

This package allows your app to send signals to [TelemetryDeck](https://telemetrydeck.com/) using the native TelemetryDeck libraries for [Kotlin](https://github.com/TelemetryDeck/KotlinSDK) and [iOS](https://github.com/TelemetryDeck/SwiftSDK).

## Getting started

- Obtain your TelemetryDeck App ID from the [Dashboard](https://dashboard.telemetrydeck.com/)

- Follow the installing instructions on [pub.dev](https://pub.dev/packages/telemetrydecksdk/install).

- Initialize the client:

```dart
void main() {
  // ensure the platform channels are available
  WidgetsFlutterBinding.ensureInitialized();
  // configure and start the client
  Telemetrydecksdk.start(
    const TelemetryManagerConfiguration(
      appID: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
    ),
  );

  runApp(const MyApp());
}
```

### Permission for internet access

Sending signals requires access to the internet so the following permissions should be granted. For more information, you can check [Flutter Cross-platform HTTP networking ](https://docs.flutter.dev/data-and-backend/networking).

#### Android

Change the app's `AndroidManifest.xml` to include:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

#### macOS

Set the `com.apple.security.network.client` entitlement to `true` in the `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements` files. You can also do this in Xcode by selecting the `macos` target, then the `Signing & Capabilities` tab, and checking `Outgoing connections (Client)` for both the Release and Debug targets of your app.

## Sending signals

Send a signal using the following method:

```dart
Telemetrydecksdk.send("signal_type")
```

## Signals with additional attributes

Append any number of custom attributes to a signal:

```dart
Telemetrydecksdk.send(
  "signal_type",
  additionalPayload: {"attributeName": "value"},
);
```

## Environment Parameters

The Flutter SDK uses the native SDKs for Android and iOS which offer a number of built-in attributes which are submitted with every signal.

For more information on how each value is calcualted, check the corresponding platform library.

The Flutter SDK adds the following additional attributes:

| Parameter name                  | Description                                 |
| ------------------------------- | ------------------------------------------- |
| `TelemetryDeck.SDK.dartVersion` | The Dart language version used during build |

## Stop sending signals

Prevent signals from being sent using the stop method:

```dart
Telemetrydecksdk.stop()
```

This also prevents previously cached signals from being sent. In order to restart sending events, you will need to call the `start` method again.

## Default Parameters

If there are parameters you would like to include with every outgoing signal, you can configure `Telemetrydecksdk` to do so instead of passing them with every call:

```dart
const TelemetryManagerConfiguration(
  // ...
        defaultParameters: {"ParameterName": "ParameterValue"}
        ),
```

## Default Prefix

If you find yourself prepending the same prefix for to your custom signals or parameters,
you can optionally configure `Telemetrydecksdk` to do this for you:

```dart
const TelemetryManagerConfiguration(
  // ...
        defaultParameterPrefix: "DemoApp.Parameter.",
        defaultSignalPrefix: "DemoApp.Signal.",
        ),
```

## Duration Signals

The SDK offers convenience methods to facilitate tracking the duration of specific objects or events.

Once started, a duration signal will be tracked internally by the SDK and upon completion, it will send the signal while also adding a `TelemetryDeck.Signal.durationInSeconds` parameter.

```dart
// start tracking, without sending a signal
TelemetryDeck.startDurationSignal("wizard_step1")

// end tracking, sends the signal including the total duration (excluding background time)
TelemetryDeck.stopAndSendDurationSignal("wizard_step1")
```

## Navigation signals

A navigation signal is a regular TelemetryDeck signal of type `TelemetryDeck.Navigation.pathChanged`. Automatic navigation tracking is available using the `navigate` and `navigateToDestination` methods:

```dart
Telemetrydecksdk.navigate("screen1", "screen2");

Telemetrydecksdk.navigateToDestination("screen3");
```

Both methods allow for a custom `clientUser` to be passed as an optional parameter:

```dart
Telemetrydecksdk.navigate("screen1", "screen2",
                      clientUser: "custom_user");
```

For more information, please check [this post](https://telemetrydeck.com/docs/articles/navigation-signals/).

## Test mode

If your app's build configuration is set to "Debug", all signals sent will be marked as testing signals. In the Telemetry Viewer app, activate **Test Mode** to see those.

If you want to manually control whether test mode is active, you can set the `testMode` field:

```dart
Telemetrydecksdk.start(
  TelemetryManagerConfiguration(
    appID: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
    testMode: true,
  ),
);
```

[Getting started with Test Mode](https://telemetrydeck.com/docs/articles/test-mode/)

## Custom Salt

By default, user identifiers are hashed by the TelemetryDeck SDK, and then sent to the Ingestion API, where we'll add a salt to the received identifier and hash it again.

This is enough for most use cases, but if you want to extra privacy conscious, you can add in you own salt on the client side. The TelemetryDeck SDK will append the salt to all user identifers before hashing them and sending them to us.

If you'd like to use a custom salt, you can do so by passing it on to the starting `TelemetryManagerConfiguration`:

```dart
Telemetrydecksdk.start(
  TelemetryManagerConfiguration(
    appID: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
    salt: "<A RANDOM STRING>",
  ),
);
```

## Custom Server

A very small subset of our customers will want to use a custom signal ingestion server or a custom proxy server. To do so, you can pass the URL of the custom server to the `TelemetryManagerConfiguration`:

```dart
Telemetrydecksdk.start(
  TelemetryManagerConfiguration(
    appID: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
    apiBaseURL: "https://nom.telemetrydeck.com",
  ),
);
```

## Logging output

By default, some logs helpful for monitoring TelemetryDeck are printed out to the console. You can enable additional logs by setting the `debug` field to `true`:

```dart
void main() {
  Telemetrydecksdk.start(
    TelemetryManagerConfiguration(
      appID: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
      debug: true,
    ),
  );
}
```
