import 'package:flutter_test/flutter_test.dart';

import 'package:scientific_calculator/main.dart';

void main() {
  testWidgets('Calculator smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScientificCalculatorApp());

    // Verify that our app starts.
    expect(find.text('Scientific Calculator'), findsOneWidget);
  });
}
