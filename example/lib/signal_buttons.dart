import 'package:flutter/material.dart';
import 'package:telemetrydecksdk/telemetrydecksdk.dart';

class SignalButtons extends StatelessWidget {
  const SignalButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        const _SectionHeader('Signals'),
        SignalButton(
          label: 'send',
          action: () => Telemetrydecksdk.send("Example.send"),
        ),
        SignalButton(
          label: 'send with payload, floatValue and clientUser',
          action: () => Telemetrydecksdk.send(
            "Example.sendWithPayload",
            clientUser: "example-user",
            additionalPayload: {"Example.source": "button", "Example.count": 3},
            floatValue: 42.5,
          ),
        ),
        const _SectionHeader('Duration'),
        SignalButton(
          label: 'startDurationSignal',
          action: () => Telemetrydecksdk.startDurationSignal(
            "Example.duration",
            parameters: {"Example.step": "one"},
          ),
        ),
        SignalButton(
          label: 'stopAndSendDurationSignal',
          action: () => Telemetrydecksdk.stopAndSendDurationSignal(
            "Example.duration",
            parameters: {"Example.outcome": "done"},
          ),
        ),
        const _SectionHeader('Navigation'),
        SignalButton(
          label: 'navigate home -> settings',
          action: () => Telemetrydecksdk.navigate("home", "settings"),
        ),
        SignalButton(
          label: 'navigateToDestination about',
          action: () => Telemetrydecksdk.navigateToDestination("about"),
        ),
        const _SectionHeader('Session and user'),
        SignalButton(
          label: 'generateNewSession',
          action: Telemetrydecksdk.generateNewSession,
        ),
        SignalButton(
          label: 'updateDefaultUser',
          action: () => Telemetrydecksdk.updateDefaultUser("example-user"),
        ),
        const _SectionHeader('Acquisition'),
        SignalButton(
          label: 'acquiredUser',
          action: () => Telemetrydecksdk.acquiredUser(
            "app-store-search",
            params: {"Example.campaign": "launch"},
          ),
        ),
        SignalButton(
          label: 'leadStarted',
          action: () => Telemetrydecksdk.leadStarted("lead-42"),
        ),
        SignalButton(
          label: 'leadConverted',
          action: () => Telemetrydecksdk.leadConverted("lead-42"),
        ),
        const _SectionHeader('Activation'),
        SignalButton(
          label: 'onboardingCompleted',
          action: () => Telemetrydecksdk.onboardingCompleted(),
        ),
        SignalButton(
          label: 'coreFeatureUsed',
          action: () => Telemetrydecksdk.coreFeatureUsed("export"),
        ),
        SignalButton(
          label: 'paywallShown',
          action: () => Telemetrydecksdk.paywallShown("export-limit"),
        ),
        const _SectionHeader('Revenue'),
        for (final event in PurchaseEvent.values)
          SignalButton(
            label: 'purchaseCompleted ${event.name}',
            action: () => _purchaseCompleted(event),
          ),
        const _SectionHeader('Referral and feedback'),
        SignalButton(
          label: 'referralSent',
          action: () =>
              Telemetrydecksdk.referralSent(receiversCount: 2, kind: "email"),
        ),
        SignalButton(
          label: 'userRatingSubmitted',
          action: () =>
              Telemetrydecksdk.userRatingSubmitted(5, comment: "Works well"),
        ),
        const _SectionHeader('Errors'),
        SignalButton(
          label: 'errorOccurred',
          action: () => Telemetrydecksdk.errorOccurred(
            "Example.error",
            category: ErrorCategory.appState,
            message: "Example error message",
            parameters: {"Example.screen": "home"},
            floatValue: 1,
          ),
        ),
      ],
    );
  }

  Future<void> _purchaseCompleted(PurchaseEvent event) {
    return Telemetrydecksdk.purchaseCompleted(
      event,
      "DE",
      "pro.yearly",
      PurchaseType.subscription,
      29990000,
      "EUR",
      offerID: "intro-offer",
    );
  }
}

class SignalButton extends StatelessWidget {
  const SignalButton({super.key, required this.label, required this.action});

  final String label;
  final Future<void> Function() action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: FilledButton.tonal(
        onPressed: () async {
          await action();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text('Sent: $label')));
        },
        child: Text(label),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
