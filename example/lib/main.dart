import 'package:flutter/material.dart';
import 'package:telemetrydecksdk/telemetrydecksdk.dart';

import 'signal_buttons.dart';

const configuration = TelemetryManagerConfiguration(
  appID: "22385F1C-3699-4F04-9D63-24CC0B2E62D8",
  namespace: "eu.headbright",
  defaultParameters: {"ExampleApp.source": "example"},
  debug: true,
  testMode: true,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Telemetrydecksdk.start(configuration);
  await Telemetrydecksdk.send("App.launched");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('TelemetryDeck example')),
        body: const SignalButtons(),
      ),
    );
  }
}
