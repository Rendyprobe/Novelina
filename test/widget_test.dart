import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    // Create a simple test app
    const testApp = MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Test App'),
        ),
      ),
    );

    // Build the test app and trigger a frame.
    await tester.pumpWidget(testApp);

    // Verify that the test text is found.
    expect(find.text('Test App'), findsOneWidget);
  });
}