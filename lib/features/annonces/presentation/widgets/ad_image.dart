import 'package:flutter/material.dart';

Color marketplaceAccent(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF63DBC7)
    : const Color(0xFF00786B);

class AdImage extends StatelessWidget {
  const AdImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fallback = Center(
      child: Icon(Icons.sell_outlined, color: colors.primary, size: 42),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primaryContainer, colors.tertiaryContainer],
        ),
      ),
      child: url.trim().isEmpty
          ? fallback
          : Image.network(
              url,
              fit: fit,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}
