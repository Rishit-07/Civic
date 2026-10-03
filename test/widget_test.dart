import 'package:flutter_test/flutter_test.dart';
import 'package:civic/main.dart';

void main() {
  testWidgets('CivicApp initializes smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CivicApp());
    expect(find.byType(CivicApp), findsOneWidget);
  });
}
