# Package Release Notes

This section refers to the process of maintaining, upgrading and publishing the current library.

## Releasing a new version

1. Create a PR to update the CHANGELOG in order to mention the changes made in the new version. This is optional, if this step is skipped, the `setupversion.sh` will create a generic entry.

2. Merge all changes into `main`.

3. Navigate to the [Set package version](https://github.com/TelemetryDeck/FlutterSDK/actions/workflows/set-version.yml) action and run it by setting the next `version`. Please note: this must be the same if you manually created a release entry in CHANGELOG.md.

🏁

## Adopting newer versions of the native SDKs

The Flutter SDK depends on the latest major version of the native SDKs. This is defined in the following locations:

On Android, the dependency is configured in `android/build.gradle`:

```
implementation 'com.telemetrydeck:kotlin-sdk:7.2.0'
```

On iOS and macOS, the dependency is configured in `darwin/telemetrydecksdk/Package.swift` using the Swift Package Manager dependency format `.package(url: "https://github.com/TelemetryDeck/SwiftSDK", exact: "3.0.0-beta.5")`.

Note: Flutter's Swift Package Manager integration resolves the SwiftSDK dependency when building the example app, updating the `Package.resolved` files in the ios and macos folders of the example project accordingly.
