import 'package:flutter/material.dart';

class SwipeHint extends StatelessWidget {
  final IconData icon;
  final String label;

  const SwipeHint({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
