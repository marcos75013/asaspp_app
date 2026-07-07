import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class FeatureTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String route;

  const FeatureTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.route,
  });

  @override
  State<FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<FeatureTile> {
  bool isPressed = false;

  bool get _isQuiz => widget.title.toLowerCase().contains('quiz');

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF42E8F4);
    const iconColor = Color(0xFF6CEFFF);

    const cardGradient = [
      Color(0xFF102A43),
      Color(0xFF071E34),
      Color(0xFF020B18),
    ];

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => isPressed = true);
      },
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: () => context.push(widget.route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..scale(isPressed ? 0.97 : 1.0)
          ..translate(0.0, isPressed ? 4.0 : 0.0),
        child: Container(
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: cardGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: borderColor,
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.18),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                if (_isQuiz) ...[
                  Positioned(
                    right: 28,
                    top: -8,
                    child: Text(
                      '?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.11),
                        fontSize: 92,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 100,
                    bottom: -14,
                    child: Text(
                      '?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.08),
                        fontSize: 68,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ] else ...[
                  Positioned(
                    right: -18,
                    top: -10,
                    child: Icon(
                      Icons.library_books_rounded,
                      size: 170,
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                ],

                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.4, sigmaY: 0.4),
                    child: Container(
                      color: Colors.white.withOpacity(0.01),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.16),
                              Colors.white.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: iconColor.withOpacity(0.55),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: iconColor.withOpacity(0.14),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isQuiz
                              ? Icons.emoji_events_outlined
                              : Icons.library_books_outlined,
                          color: iconColor,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isQuiz
                                  ? "QUIZ PLONGÉE"
                                  : "BIBLIOTHÈQUE",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isQuiz
                                  ? "Teste tes connaissances"
                                  : "Documents, liens et ressources",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: Colors.white.withOpacity(0.84),
                                fontSize: 15,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, curve: Curves.easeOutCubic);
  }
}