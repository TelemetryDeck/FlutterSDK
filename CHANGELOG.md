## 2.5.0

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/2.5.0


## 2.4.0

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/2.4.0

- This update adds support for duration signals and custom namespace configuration

## 2.3.0

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/2.3.0

- This update introduces the latest features from the native SDKs, including support for the new session tracking and acquisition parameters.

- The SwiftSDK for macOS has been updated to version [2.9.1](https://github.com/TelemetryDeck/SwiftSDK/releases/tag/2.9.1)
- The SwiftSDK for iOS has been updated to version [2.9.1](https://github.com/TelemetryDeck/SwiftSDK/releases/tag/2.9.1)
- The KotlinSDK for Android has been updated to [6.0.1](https://github.com/TelemetryDeck/KotlinSDK/releases/tag/6.0.1)

## 2.2.0

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/2.2.0

## 2.1.0

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/2.1.0

- It's now possible to set defaultSignalPrefix, defaultParameterPrefix as well as a map of defaultParameters in the `TelemetryManagerConfiguration` class. This allows you to set default values for all signals and parameters sent by the SDK.

- The SwiftSDK for macOS has been updated to version [2.7.2](https://github.com/TelemetryDeck/SwiftSDK/releases/tag/2.7.2)
- The SwiftSDK for iOS has been updated to version [2.7.2](https://github.com/TelemetryDeck/SwiftSDK/releases/tag/2.7.2)
- The KotlinSDK for Android has been updated to [4.1.0](https://github.com/TelemetryDeck/KotlinSDK/releases/tag/4.1.0)

### Notes

- The minimum Kotlin compiler version has been raised to [2.0.21](https://kotlinlang.org/docs/releases.html#release-details) and can be configured by setting `ext.kotlin_version = '2.0.21'` in your `build.gradle` file.

## 2.0.1

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/2.0.1
- The SwiftSDK for macOS has been updated to the latest version
- Added the option to provide a custom salt for macOS targets

## 2.0.0

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/2.0.0
- The KotlinSDK has been updated to [version 4.0.2](https://github.com/TelemetryDeck/KotlinSDK/releases/tag/4.0.2) introducing automatic generation of random user identifiers ([link](https://github.com/TelemetryDeck/KotlinSDK/issues/14)) and other improvements.
- Added the option to provide a custom salt for consistent user identifiers.

## 1.0.0

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/1.0.0
- This version introduces the Grand Rename for all native SDKs. You can read more about the motivation behind these changes [here](https://telemetrydeck.com/docs/articles/grand-rename/).
- Upgrade to the latest Kotlin SDK version introducing a new `TelemetryDeck` class and [more](https://github.com/TelemetryDeck/KotlinSDK/releases/tag/3.0.3).
- Upgrade to the latest Swift SDK version with [various improvements](https://github.com/TelemetryDeck/SwiftSDK/compare/2.2.4...2.6.1).

## 0.6.0

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/0.6.0
- Update coordinates for Kotlin SDK to Maven Central

## 0.5.1

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/0.5.1
- Fix a possible crash when calling `stop()`.

## 0.5.0

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/0.5.0
- Add support for navigation signals
- Upgrades to the latest version of the Swift and Kotlin SDKs

## 0.4.0

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/0.4.0
- Updated `flutter_lints` dependency
- Updated package to make it compliant with flutter package rules
- Made all calls in `Telemetrydecksdk` class static - no need to create an instance anymore
- `additionalPayload` takes a `Map<String, dynamic>`now instead of a `Map<String, String>` and values will now be stringified automatically
- [Fixes](https://github.com/TelemetryDeck/KotlinSDK/pull/27) an issue which causes signals from Android to always appear in test mode.

## 0.3.0

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/0.3.0

## 0.2.0

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/0.2.0

## 0.1.0

- TelemetryDeck SDK is now available for macOS apps
- Improvements to documentation and pub.dev listing

## 0.0.5

- https://github.com/TelemetryDeck/FlutterSDK/releases/tag/0.0.5

## 0.0.4

- The initial release of TelemetryDeck SDK for Flutter

## 0.0.3

- The initial release of TelemetryDeck SDK for Flutter
