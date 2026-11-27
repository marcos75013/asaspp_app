import 'package:asaspp_app/core/theme/pulse_appearance.dart';
import 'package:asaspp_app/core/theme/pulse_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Pulse text has AA contrast on cards in both themes', () {
    for (final brightness in Brightness.values) {
      final scheme = PulseTheme.build(brightness).colorScheme;
      for (final text in [scheme.onSurface, scheme.onSurfaceVariant]) {
        final levels = [
          text.computeLuminance(),
          scheme.surface.computeLuminance(),
        ]..sort();
        expect(
          (levels.last + .05) / (levels.first + .05),
          greaterThanOrEqualTo(4.5),
        );
      }
    }
  });

  test(
    'Appearance defaults to system and restores the saved selection',
    () async {
      SharedPreferences.setMockInitialValues({});
      final first = PulseAppearance();
      await first.restore(() => true);
      expect(first.value, ThemeMode.system);
      await first.select(ThemeMode.dark, () => true);
      first.dispose();

      final restored = PulseAppearance();
      await restored.restore(() => true);
      expect(restored.value, ThemeMode.dark);
      restored.dispose();
    },
  );
}
