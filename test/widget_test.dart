import 'package:flutter_test/flutter_test.dart';
import 'package:alquran/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuranApp());

    // Verify that the login screen is displayed
    expect(find.text('Sign In'), findsOneWidget);
    
    // You can add more test cases here as needed
  });
}