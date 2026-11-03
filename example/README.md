# telemetrydecksdk example

A small test app for the TelemetryDeck Flutter plugin.

## Run the example on a device

```bash
flutter devices
flutter run -d <device-id>
```

`flutter devices` lists the id of every connected Android device, iPhone and simulator; the macOS desktop id is `macos`.


## Run the integration test

`integration_test/telemetry_smoke_test.dart` starts the SDK itself, awaits every public API method once with `IntegrationTest.*` signal names, then polls the TelemetryDeck query API with the personal access token `TD_PAT` for up to three minutes and fails unless signals of this run arrived. `TD_RUN_ID` is attached to every signal as the `runId` default parameter so a run can be told apart when querying; without it the test uses `<platform>-<timestamp>`.

```bash
flutter test integration_test -d <device-id> --dart-define=TD_PAT=<token> [--dart-define=TD_RUN_ID=<run-id>]
```

From the plugin root the same command is available as `make smoke-test DEVICE=<device-id> PAT=<token> [RUN_ID=<run-id>]`.

## Query what arrived

Open the app in the [TelemetryDeck dashboard](https://dashboard.telemetrydeck.com) with test mode enabled to see the signals as they arrive. Filter by the `runId` parameter to see a single integration test run.
