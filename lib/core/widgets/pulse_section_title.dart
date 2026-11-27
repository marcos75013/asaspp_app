import 'package:flutter/material.dart';

class PulseSectionTitle extends StatelessWidget {
  final String label;
  const PulseSectionTitle(this.label, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 10),
    child: Semantics(
      header: true,
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
