<a href="https://pub.dev/packages/telemetrydecksdk"><img src="https://img.shields.io/pub/v/telemetrydecksdk.svg" alt="Pub"></a>


# TelemetryDeck SDK for Flutter

This package allows your app to send signals to [TelemetryDeck](https://telemetrydeck.com/) using the native TelemetryDeck libraries for [Kotlin](https://github.com/TelemetryDeck/KotlinSDK) (Android) and [Swift](https://github.com/TelemetryDeck/SwiftSDK) (iOS and macOS).

## Requirements

- Flutter `>=3.47.0` (Dart `^3.13.0`)
- iOS 15.0 or later, macOS 12.0 or later (via Swift Package Manager)
- Android API 24 or later, Kotlin 2.4.10

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
      namespace: "my-namespace",
    ),
  );

  runApp(const MyApp());
}
```

- `namespace` is required, see [Namespaces](https://telemetrydeck.com/docs/articles/namespaces/).

- `start` returns a `Future`. On Android, signals sent before it completes are dropped, so `await` it if you send signals right after starting. On iOS and macOS they are queued and sent once the native SDK is initialized.

For a step by step walkthrough, see the [Flutter Setup Guide](https://telemetrydeck.com/docs/guides/flutter-setup/).

### Permission for internet access

Sending signals requires access to the internet. For more information, you can check [Flutter Cross-platform HTTP networking ](https://docs.flutter.dev/data-and-backend/networking).

#### Android

The plugin's `AndroidManifest.xml` declares the `android.permission.INTERNET` permission and the manifest merger adds it to your app, so no change is needed.

#### macOS

Set the `com.apple.security.network.client` entitlement to `true` in the `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements` files. You can also do this in Xcode by selecting the `macos` target, then the `Signing & Capabilities` tab, and checking `Outgoing connections (Client)` for both the Release and Debug targets of your app.

## Sending signals

Send a signal using the following method:

```dart
Telemetrydecksdk.send("signal_type")
```

## Signals with additional attributes

Append any number of custom attributes to a signal. Values are converted to strings before they are sent:

```dart
Telemetrydecksdk.send(
  "signal_type",
  additionalPayload: {"attributeName": "value", "count": 3},
);
```

A signal can also carry a numeric `floatValue` and a `clientUser` that overrides the default user for this signal only:

```dart
Telemetrydecksdk.send(
  "signal_type",
  clientUser: "user@example.com",
  floatValue: 42.5,
);
```

User identifiers are hashed on the device before they are sent.

## Environment Parameters

The Flutter SDK uses the native SDKs for Android, iOS and macOS which offer a number of built-in attributes which are submitted with every signal. See [Default Parameters](https://telemetrydeck.com/docs/ingest/default-parameters/) for the full list.

For more information on how each value is calculated, check the corresponding platform library: [Kotlin SDK environment parameters](https://github.com/TelemetryDeck/KotlinSDK#environment-parameters) and [Swift SDK parameters](https://github.com/TelemetryDeck/SwiftSDK#parameters).

The Flutter SDK sets the following attributes itself, replacing the values of the native SDK:

| Parameter name                      | Description                                 |
| ----------------------------------- | ------------------------------------------- |
| `TelemetryDeck.SDK.name`            | `Flutter SDK`                               |
| `TelemetryDeck.SDK.version`         | The version of this package                 |
| `TelemetryDeck.SDK.nameAndVersion`  | Name and version combined                   |
| `TelemetryDeck.SDK.dartVersion`     | The Dart language version used during build |

## Stop sending signals

Prevent signals from being sent using the stop method:

```dart
Telemetrydecksdk.stop()
```

Signals sent after `stop` are ignored until you call `start` again. Signals that are still cached are kept on disk and sent after the next call to `start`. On iOS and macOS, `stop` first sends one batch of cached signals immediately; on Android nothing is sent until the next `start`.

## Default Parameters

If there are parameters you would like to include with every outgoing signal, you can configure `Telemetrydecksdk` to do so instead of passing them with every call:

```dart
const TelemetryManagerConfiguration(
  // ...
  defaultParameters: {"ParameterName": "ParameterValue"},
),
```

## Default Prefix

If you find yourself prepending the same prefix to your custom signals or parameters,
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
Telemetrydecksdk.startDurationSignal("wizard_step1")

// end tracking, sends the signal including the total duration (excluding background time)
Telemetrydecksdk.stopAndSendDurationSignal("wizard_step1")
```

Both methods accept an optional `parameters` map which is merged into the final signal. For more information, see [Duration Events](https://telemetrydeck.com/docs/articles/duration-events/).

## Navigation signals

A navigation signal is a regular TelemetryDeck signal of type `TelemetryDeck.Navigation.pathChanged`. Send one with the `navigate` and `navigateToDestination` methods:

```dart
Telemetrydecksdk.navigate("screen1", "screen2");

Telemetrydecksdk.navigateToDestination("screen3");
```

Both methods allow for a custom `clientUser` to be passed as an optional parameter:

```dart
Telemetrydecksdk.navigate("screen1", "screen2",
                      clientUser: "custom_user");
```

For more information, please check [Navigation Events](https://telemetrydeck.com/docs/articles/navigation-events/).

## Sessions and users

Start a new session, for example when a user signs out, or change the default user applied to all following signals:

```dart
Telemetrydecksdk.generateNewSession();

Telemetrydecksdk.updateDefaultUser("user@example.com");
```

Both methods require the client to be started.

## Acquisition and activation

Convenience methods send the signals used by the [Pirate Metrics](https://telemetrydeck.com/docs/basics/pirate-metrics/) insights for [acquisition](https://telemetrydeck.com/docs/basics/acquisition/) and [activation](https://telemetrydeck.com/docs/basics/activation/). Each accepts optional `params` and `customUserID` arguments:

```dart
Telemetrydecksdk.acquiredUser("app-store-search", params: {"campaign": "launch"});
Telemetrydecksdk.leadStarted("lead-42");
Telemetrydecksdk.leadConverted("lead-42");
Telemetrydecksdk.onboardingCompleted();
Telemetrydecksdk.coreFeatureUsed("export");
Telemetrydecksdk.paywallShown("export-limit");
```

## Purchases

Report purchases, free trials and trial conversions with `purchaseCompleted`. The price is given in micros of the currency unit, so `29990000` is `29.99`:

```dart
Telemetrydecksdk.purchaseCompleted(
  PurchaseEvent.purchaseCompleted,
  "DE",
  "pro.yearly",
  PurchaseType.subscription,
  29990000,
  "EUR",
  offerID: "intro-offer",
);
```

`PurchaseEvent` is one of `purchaseCompleted`, `freeTrialStarted` or `convertedFromFreeTrial`, `PurchaseType` is `subscription` or `oneTimePurchase`. For more information, see [Tracking Purchases](https://telemetrydeck.com/docs/articles/preset-purchases/).

## Referrals and ratings

```dart
Telemetrydecksdk.referralSent(receiversCount: 2, kind: "email");

Telemetrydecksdk.userRatingSubmitted(5, comment: "Works well");
```

`rating` must be between 0 and 10. Ratings outside this range are not sent and the native SDK logs an error.

## Errors

Report an error with a stable identifier, an optional category and message:

```dart
Telemetrydecksdk.errorOccurred(
  "Export.failed",
  category: ErrorCategory.appState,
  message: "Disk full",
  parameters: {"screen": "export"},
);
```

The native SDKs recognise the categories `thrownException`, `userInput` and `appState`. For more information, see [Tracking Errors](https://telemetrydeck.com/docs/articles/preset-errors/).

## Test mode

If `testMode` is not set, debug builds send testing signals and release builds send regular signals: on iOS and macOS the SwiftSDK checks the `DEBUG` compilation condition, on Android the KotlinSDK checks whether the app is debuggable. In the Telemetry Viewer app, activate **Test Mode** to see testing signals.

If you want to manually control whether test mode is active, you can set the `testMode` field:

```dart
Telemetrydecksdk.start(
  TelemetryManagerConfiguration(
    appID: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
    namespace: "my-namespace",
    testMode: true,
  ),
);
```

[Getting started with Test Mode](https://telemetrydeck.com/docs/articles/test-mode/)

## Custom Salt

By default, user identifiers are hashed by the TelemetryDeck SDK, and then sent to the Ingestion API, where we'll add a salt to the received identifier and hash it again.

This is enough for most use cases, but if you want to be extra privacy conscious, you can add in your own salt on the client side. The TelemetryDeck SDK will append the salt to all user identifiers before hashing them and sending them to us.

If you'd like to use a custom salt, you can do so by passing it on to the starting `TelemetryManagerConfiguration`:

```dart
Telemetrydecksdk.start(
  TelemetryManagerConfiguration(
    appID: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
    namespace: "my-namespace",
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
    namespace: "my-namespace",
    apiBaseURL: "https://nom.telemetrydeck.com",
  ),
);
```

## Logging output

On iOS and macOS, some logs helpful for monitoring TelemetryDeck are printed out by default; on Android the native SDK logs nothing by default. You can enable additional logs on all platforms by setting the `debug` field to `true`:

```dart
void main() {
  Telemetrydecksdk.start(
    TelemetryManagerConfiguration(
      appID: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
      namespace: "my-namespace",
      debug: true,
    ),
  );
}
```

On iOS and macOS the logs are written to the unified logging system with subsystem `TelemetryDeck`. On Android the KotlinSDK prints them to standard output as `D/TELEMETRYDECK:` and `E/TELEMETRYDECK:` lines, while errors raised inside the plugin are always logged with the Logcat tag `TelemetryDeck`.
