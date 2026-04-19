import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:germana/widgets/ride_map_snippet.dart';

void main() {
  testWidgets('RideMapSnippet shows fallback route preview when coords are missing',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RideMapSnippet(
            pickupLabel: 'UKM Main Gate',
            destinationLabel: 'TBS',
          ),
        ),
      ),
    );

    expect(find.text('Route preview'), findsOneWidget);
    expect(find.text('UKM Main Gate'), findsOneWidget);
    expect(find.text('TBS'), findsOneWidget);
  });
}
