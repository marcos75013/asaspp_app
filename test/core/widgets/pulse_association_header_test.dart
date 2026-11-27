import 'package:asaspp_app/core/theme/pulse_theme.dart';
import 'package:asaspp_app/core/widgets/pulse_association_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('association switcher fits a narrow header in $brightness', (
      tester,
    ) async {
      var switched = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.build(brightness),
          home: Scaffold(
            body: SizedBox(
              width: 215,
              child: PulseAssociationHeader(
                name: 'Association sportive et culturelle très longue',
                onSwitch: () => switched = true,
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.groups_outlined), findsOneWidget);
      await tester.tap(find.byTooltip('Changer d’association'));
      expect(switched, isTrue);
    });
  }
}
