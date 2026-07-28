import 'package:flutter_test/flutter_test.dart';
import 'package:robox/app.dart';

void main() {
  testWidgets('Robox App Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RoboxApp());

    // Verify that the login screen title is present.
    expect(find.text('ROBOX'), findsOneWidget);
    expect(find.text('INDUSTRIAL OS V1.0'), findsOneWidget);
  });
}
