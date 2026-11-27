import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PulseAppearance extends ValueNotifier<ThemeMode> {
  PulseAppearance() : super(ThemeMode.system);

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  static const _key = 'pulse.theme-mode';

  Future<void> restore(bool Function() isActive) async {
    final prefs = await SharedPreferences.getInstance();
    if (_disposed || !isActive()) return;
    value = ThemeMode.values.firstWhere(
      (mode) => mode.name == prefs.getString(_key),
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> select(ThemeMode mode, bool Function() isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
    if (!_disposed && isActive()) value = mode;
  }
}

class PulseAppearanceScope extends InheritedNotifier<PulseAppearance> {
  const PulseAppearanceScope({
    super.key,
    required PulseAppearance appearance,
    required super.child,
  }) : super(notifier: appearance);

  static PulseAppearance? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PulseAppearanceScope>()?.notifier;
}
