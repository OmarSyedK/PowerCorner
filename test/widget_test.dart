import 'package:flutter_test/flutter_test.dart';
import 'package:powercorner/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PowerCornerApp(onboarded: false));
    expect(find.text('POWERCORNER'), findsNothing); // onboarding shown
  });
}
