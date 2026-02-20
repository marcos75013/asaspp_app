import 'package:flutter/material.dart';

class UnderwaterBackground extends StatelessWidget {
  const UnderwaterBackground({
    super.key,
    this.backgroundImageAsset,
  });

  final String? backgroundImageAsset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Dégradé “océan”
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A6FD8), // bleu océan
                Color(0xFF063A7A), // plus profond
                Color(0xFF021B38), // abyss
              ],
            ),
          ),
        ),

        // Optionnel : image de fond très discrète
        if (backgroundImageAsset != null)
          Opacity(
            opacity: 0.10,
            child: Image.asset(
              backgroundImageAsset!,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),

        // Petite “lumière” douce en haut
        Positioned(
          top: -120,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.16),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
