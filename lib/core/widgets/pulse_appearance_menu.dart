import 'package:flutter/material.dart';

import '../theme/pulse_appearance.dart';

class PulseAppearanceMenu extends StatelessWidget {
  final bool tile;

  const PulseAppearanceMenu({super.key, this.tile = false});

  static const labels = {
    ThemeMode.system: 'Système',
    ThemeMode.light: 'Clair',
    ThemeMode.dark: 'Sombre',
  };

  @override
  Widget build(BuildContext context) {
    final appearance = PulseAppearanceScope.maybeOf(context);
    if (appearance == null) return const SizedBox.shrink();
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appearance,
      builder: (context, mode, _) => PopupMenuButton<ThemeMode>(
        tooltip: 'Apparence',
        initialValue: mode,
        onSelected: (mode) async {
          try {
            await appearance.select(mode, () => true);
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Impossible de mémoriser le thème.'),
                ),
              );
            }
          }
        },
        itemBuilder: (_) => [
          for (final entry in labels.entries)
            PopupMenuItem(value: entry.key, child: Text(entry.value)),
        ],
        icon: tile ? null : const Icon(Icons.brightness_6_outlined),
        child: tile
            ? ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: const Text('Apparence'),
                subtitle: Text(labels[mode]!),
                trailing: const Icon(Icons.chevron_right),
              )
            : null,
      ),
    );
  }
}
