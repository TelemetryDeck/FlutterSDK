import 'dart:async';

import 'package:flutter/material.dart';
import 'package:telemetrydecksdk/telemetry_deck_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Telemetrydecksdk.start(
    const TelemetryManagerConfiguration(
      appID: "A4CAE055-857C-45F8-8C6B-335E3617050D",
      debug: true,
      testMode: true,
    ),
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
              const SizedBox(height: 10), // Adds some space between the text and the button
              ElevatedButton(
                onPressed: () {
                  // Define the action when the button is pressed
                  Telemetrydecksdk.send("button_clicked");

                  // Provide additional user information
                  Telemetrydecksdk.send(
                    "button_clicked",
                    clientUser: "user",
                  );

                  // Provide additional payload information
                  Telemetrydecksdk.send(
                    "button_clicked",
                    additionalPayload: {"mapKey": "mapValue"},
                  );
                },
                child: const Text('Press Me'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
