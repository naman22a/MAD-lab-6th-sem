import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exp_11/main.dart';

void main() {
  testWidgets('Counter UI test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Check initial value
    expect(find.text('Value: 0'), findsOneWidget);

    // Tap increment button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify updated value
    expect(find.text('Value: 1'), findsOneWidget);
  });
}
