import 'dart:async';

import 'package:flutter/material.dart';
import 'package:telemetrydecksdk/telemetrydecksdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Telemetrydecksdk.start(
    const TelemetryManagerConfiguration(
        appID: "22385F1C-3699-4F04-9D63-24CC0B2E62D8",
        defaultParameterPrefix: "DemoApp.Parameter.",
        defaultSignalPrefix: "DemoApp.Signal.",
        defaultParameters: {"ParameterName": "ParameterValue"},
        debug: true,
        testMode: true),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Hello !'),
              const SizedBox(
                  height:
                      10), // Adds some space between the text and the button
              ElevatedButton(
                onPressed: () {
                  // Send a signal type to TelemetryDeck
                  Telemetrydecksdk.send("button_clicked");
                  // You can optionally attach parameters to the signal
                  Telemetrydecksdk.send(
                    "button_clicked",
                    clientUser: "user",
                  );
                  // Provide additional payload information
                  Telemetrydecksdk.send(
                    "button_clicked",
                    additionalPayload: {"mapKey": "mapValue"},
                  );
                  // Signal navigation
                  Telemetrydecksdk.navigate("home", "settings");

                  Telemetrydecksdk.navigate("settings", "about",
                      clientUser: "custom_user");

                  Telemetrydecksdk.navigateToDestination("landing");
                },
                child: const Text('button_clicked'),
              ),
              ElevatedButton(
                onPressed: () {
                  Telemetrydecksdk.send(
                    "button_clicked",
                    clientUser: "user",
                  );
                  // Provide additional payload information
                  Telemetrydecksdk.send(
                    "button_clicked",
                    additionalPayload: {"mapKey": "mapValue"},
                  );
                  // Signal navigation
                  Telemetrydecksdk.navigate("home", "settings");

                  Telemetrydecksdk.navigate("settings", "about",
                      clientUser: "custom_user");

                  Telemetrydecksdk.navigateToDestination("landing");
                },
                child: const Text('button_clicked + Params'),
              ),
              ElevatedButton(
                onPressed: () {
                  Telemetrydecksdk.startDurationSignal("signal1");
                },
                child: const Text('Start duration signal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Telemetrydecksdk.stopAndSendDurationSignal("signal1");
                },
                child: const Text('Stop duration signal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
