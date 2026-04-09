import 'package:flutter_test/flutter_test.dart';
import 'package:germana/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(GermanaApp());
    expect(find.text('germana'), findsOneWidget);
  });
}
