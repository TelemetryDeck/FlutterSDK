import 'package:flutter/material.dart';
import 'dart:async';

import 'package:telemetrydecksdk/telemetry_manager_configuration.dart';
import 'package:telemetrydecksdk/telemetrydecksdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Telemetrydecksdk.start(TelemetryManagerConfiguration(
      appID: "your TelemetryDeck App ID", debug: true, testMode: true));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _telemetrydecksdkPlugin = Telemetrydecksdk();

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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Send a signal type to TelemetryDeck
                  _telemetrydecksdkPlugin.send("button_clicked");
                  // You can optionally attach parameters to the signal
                  _telemetrydecksdkPlugin.send("button_clicked",
                      clientUser: "user");
                  _telemetrydecksdkPlugin.send("button_clicked",
                      additionalPayload: {"mapKey": "mapValue"});
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
