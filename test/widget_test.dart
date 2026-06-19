import 'package:flutter_test/flutter_test.dart';

import 'package:tareacrud/main.dart';

void main() {
  testWidgets('CheapShark App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CheapSharkApp());

    // Verify that our home page loaded.
    expect(find.text('CHEAPSHARK DEALS'), findsOneWidget);
  });
}
