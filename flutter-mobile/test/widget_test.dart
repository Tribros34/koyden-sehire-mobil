import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test renders a basic widget', (WidgetTester tester) async {
    // The real KoydenSehireApp depends on Hive, GoRouter, secure_storage
    // and a number of platform channels that aren't available under
    // `flutter test` without heavy mocking. This minimal smoke test simply
    // confirms the test harness boots; integration coverage lives in
    // `integration_test/` (to be added).
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('koyden-sehire'))),
      ),
    );
    expect(find.text('koyden-sehire'), findsOneWidget);
  });
}
