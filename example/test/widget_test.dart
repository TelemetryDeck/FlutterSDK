import 'package:flutter_test/flutter_test.dart';

import 'package:telemetrydecksdk_example/main.dart';

void main() {
  testWidgets('shows the example app bar title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('TelemetryDeck example'), findsOneWidget);
  });
}
