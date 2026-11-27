import 'package:asaspp_app/core/theme/pulse_appearance.dart';
import 'package:asaspp_app/core/widgets/pulse_appearance_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('changing appearance updates the whole app and persists', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final appearance = PulseAppearance();
    addTearDown(appearance.dispose);
    await tester.pumpWidget(
      PulseAppearanceScope(
        appearance: appearance,
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: appearance,
          builder: (_, mode, _) => MaterialApp(
            themeMode: mode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: Scaffold(
              body: Column(
                children: [
                  const PulseAppearanceMenu(tile: true),
                  Builder(
                    builder: (context) => Text(
                      'Autre écran : ${Theme.of(context).brightness.name}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Apparence'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sombre'));
    await tester.pumpAndSettle();
    expect(find.text('Autre écran : dark'), findsOneWidget);
    final restored = PulseAppearance();
    addTearDown(restored.dispose);
    await restored.restore(() => true);
    expect(restored.value, ThemeMode.dark);
  });
}
