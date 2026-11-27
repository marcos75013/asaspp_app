import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PulseAppearance extends ValueNotifier<ThemeMode> {
  PulseAppearance() : super(ThemeMode.system);

  static const _key = 'pulse.theme-mode';

  Future<void> restore(bool Function() isActive) async {
    final prefs = await SharedPreferences.getInstance();
    if (!isActive()) return;
    value = ThemeMode.values.firstWhere(
      (mode) => mode.name == prefs.getString(_key),
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> select(ThemeMode mode, bool Function() isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
    if (isActive()) value = mode;
  }
}
