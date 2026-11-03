import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:telemetrydecksdk/telemetrydecksdk.dart';

import 'delivered_signals.dart';

const deliveryTimeout = Duration(minutes: 3);
const deliveryPollInterval = Duration(seconds: 15);
const personalAccessToken = String.fromEnvironment("TD_PAT");
const providedRunId = String.fromEnvironment("TD_RUN_ID");

final runId = providedRunId.isNotEmpty
    ? providedRunId
    : "${Platform.operatingSystem}-${DateTime.now().millisecondsSinceEpoch}";

final configuration = TelemetryManagerConfiguration(
  appID: "22385F1C-3699-4F04-9D63-24CC0B2E62D8",
  namespace: "eu.headbright",
  defaultParameters: {"runId": runId},
  debug: true,
  testMode: true,
);

const expectedSignalTypes = {
  "IntegrationTest.send",
  "IntegrationTest.sendWithPayload",
  "IntegrationTest.duration",
  "TelemetryDeck.Navigation.pathChanged",
  "TelemetryDeck.Acquisition.userAcquired",
  "TelemetryDeck.Acquisition.leadStarted",
  "TelemetryDeck.Acquisition.leadConverted",
  "TelemetryDeck.Activation.onboardingCompleted",
  "TelemetryDeck.Activation.coreFeatureUsed",
  "TelemetryDeck.Revenue.paywallShown",
  "TelemetryDeck.Purchase.completed",
  "TelemetryDeck.Purchase.freeTrialStarted",
  "TelemetryDeck.Purchase.convertedFromTrial",
  "TelemetryDeck.Referral.sent",
  "TelemetryDeck.Referral.userRatingSubmitted",
  "TelemetryDeck.Error.occurred",
};

Future<Set<String>> awaitDeliveredSignalTypes() async {
  final deadline = DateTime.now().add(deliveryTimeout);
  var delivered = <String>{};
  while (!delivered.containsAll(expectedSignalTypes) &&
      DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(deliveryPollInterval);
    delivered = await deliveredSignalTypes(
      personalAccessToken: personalAccessToken,
      namespace: configuration.namespace,
      appID: configuration.appID,
      runId: runId,
    );
  }
  return delivered;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'every public API method completes and signals get transmitted',
    (tester) async {
      expect(personalAccessToken, isNotEmpty,
          reason: "pass --dart-define=TD_PAT=<token> to verify delivery");
      await Telemetrydecksdk.start(configuration);

      await Telemetrydecksdk.send("IntegrationTest.send");
      await Telemetrydecksdk.send(
        "IntegrationTest.sendWithPayload",
        clientUser: "integration-user",
        additionalPayload: {"IntegrationTest.source": "test", "count": 3},
        floatValue: 42.5,
      );

      await Telemetrydecksdk.startDurationSignal(
        "IntegrationTest.duration",
        parameters: {"IntegrationTest.step": "one"},
      );
      await Telemetrydecksdk.stopAndSendDurationSignal(
        "IntegrationTest.duration",
        parameters: {"IntegrationTest.outcome": "done"},
      );

      await Telemetrydecksdk.navigate(
        "IntegrationTest.home",
        "IntegrationTest.settings",
      );
      await Telemetrydecksdk.navigateToDestination(
        "IntegrationTest.about",
        clientUser: "integration-user",
      );

      await Telemetrydecksdk.generateNewSession();
      await Telemetrydecksdk.updateDefaultUser("integration-default-user");

      await Telemetrydecksdk.acquiredUser(
        "IntegrationTest.channel",
        params: {"IntegrationTest.campaign": "launch"},
      );
      await Telemetrydecksdk.leadStarted("IntegrationTest.lead");
      await Telemetrydecksdk.leadConverted("IntegrationTest.lead");

      await Telemetrydecksdk.onboardingCompleted(
        params: {"IntegrationTest.steps": "3"},
      );
      await Telemetrydecksdk.coreFeatureUsed("IntegrationTest.feature");
      await Telemetrydecksdk.paywallShown("IntegrationTest.paywall");

      for (final event in PurchaseEvent.values) {
        await Telemetrydecksdk.purchaseCompleted(
          event,
          "DE",
          "IntegrationTest.product",
          PurchaseType.subscription,
          29990000,
          "EUR",
          offerID: "IntegrationTest.offer",
          params: {"IntegrationTest.event": event.name},
        );
      }

      await Telemetrydecksdk.referralSent(
        receiversCount: 2,
        kind: "IntegrationTest.referral",
      );
      await Telemetrydecksdk.userRatingSubmitted(
        5,
        comment: "IntegrationTest.rating",
      );
      await Telemetrydecksdk.errorOccurred(
        "IntegrationTest.error",
        category: ErrorCategory.appState,
        message: "IntegrationTest error message",
        parameters: {"IntegrationTest.screen": "home"},
        floatValue: 1,
        customUserID: "integration-user",
      );

      final delivered = await awaitDeliveredSignalTypes();
      await Telemetrydecksdk.stop();

      expect(delivered, containsAll(expectedSignalTypes),
          reason: "signals with runId $runId missing from TelemetryDeck");
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
