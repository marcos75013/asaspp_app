import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class BubblesLayer extends StatefulWidget {
  const BubblesLayer({super.key});

  @override
  State<BubblesLayer> createState() => _BubblesLayerState();
}

class _BubblesLayerState extends State<BubblesLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Bubble> _bubbles;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    final rnd = Random(42); // seed stable → animation identique à chaque run

    _bubbles = List.generate(22, (_) {
      return _Bubble(
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        radius: lerpDouble(6, 16, rnd.nextDouble())!,
        speed: lerpDouble(0.25, 1.1, rnd.nextDouble())!,
        drift: lerpDouble(-0.12, 0.12, rnd.nextDouble())!,
        opacity: lerpDouble(0.18, 0.35, rnd.nextDouble())!,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _BubblesPainter(
            animation: _controller,
            bubbles: _bubbles,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _BubblesPainter extends CustomPainter {
  _BubblesPainter({
    required this.animation,
    required this.bubbles,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<_Bubble> bubbles;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;

    for (final bubble in bubbles) {
      // Position verticale (monte en boucle)
      final y = (bubble.y - t * bubble.speed) % 1.0;

      // Léger mouvement horizontal sinusoïdal
      final x =
          (bubble.x + sin((t * 2 * pi) + bubble.x * 6) * bubble.drift) % 1.0;

      final offset = Offset(
        x * size.width,
        y * size.height,
      );

      // Contour externe (épais & doux)
      final outerPaint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..isAntiAlias = true;

      // Contour interne (net)
      final innerPaint = Paint()
        ..color = Colors.white.withOpacity(bubble.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..isAntiAlias = true;

      canvas.drawCircle(offset, bubble.radius, outerPaint);
      canvas.drawCircle(offset, bubble.radius, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblesPainter oldDelegate) => false;
}

class _Bubble {
  _Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.drift,
    required this.opacity,
  });

  final double x;
  final double y;
  final double radius;
  final double speed;
  final double drift;
  final double opacity;
}
