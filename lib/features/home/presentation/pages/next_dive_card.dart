import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/next_event_model.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/triangle_clipper.dart';

class NextDiveCard extends StatefulWidget {
  final DiveType type;
  final bool highlighted;

  const NextDiveCard({
    super.key,
    required this.type,
    this.highlighted = false,
  });

  @override
  State<NextDiveCard> createState() => _NextDiveCardState();
}

class _NextDiveCardState extends State<NextDiveCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(_fade);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final event = state.nextEvents[widget.type];
        if (event == null) return const SizedBox();

        return FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD4AF37)
                              .withOpacity(widget.highlighted ? 0.9 : 0.5),
                          width: widget.highlighted ? 2 : 1.5,
                        ),
                        boxShadow: widget.highlighted
                            ? [
                          BoxShadow(
                            color: const Color(0xFFD4AF37)
                                .withOpacity(0.35),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ]
                            : [],
                      ),
                      child: Stack(
                        children: [
                          /// ───── CONTENU ─────
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.site,
                                style: AppTextStyles.headline.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _InfoLine(
                                icon: Icons.calendar_today,
                                text: event.date,
                              ),
                              const SizedBox(height: 6),
                              _InfoLine(
                                icon: Icons.access_time,
                                text: event.time,
                              ),
                              const SizedBox(height: 16),

                              /// 🎯 BOUTONS (UNE SEULE LIGNE)
                              Row(
                                children: [
                                  Expanded(
                                    child: _MiniActionButton(
                                      label: 'Je viens',
                                      icon: Icons.check,
                                      color: Colors.green,
                                      selected: event.participation ==
                                          ParticipationStatus.going,
                                      onTap: () => context
                                          .read<HomeCubit>()
                                          .setParticipation(
                                        widget.type,
                                        ParticipationStatus.going,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _MiniActionButton(
                                      label: 'Peut-être',
                                      icon: Icons.help_outline,
                                      color: Colors.orange,
                                      selected: event.participation ==
                                          ParticipationStatus.maybe,
                                      onTap: () => context
                                          .read<HomeCubit>()
                                          .setParticipation(
                                        widget.type,
                                        ParticipationStatus.maybe,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _MiniActionButton(
                                      label: 'Non',
                                      icon: Icons.close,
                                      color: Colors.red,
                                      selected: event.participation ==
                                          ParticipationStatus.notGoing,
                                      onTap: () => context
                                          .read<HomeCubit>()
                                          .setParticipation(
                                        widget.type,
                                        ParticipationStatus.notGoing,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          /// ───── IMAGE TRIANGLE ─────
                          Positioned(
                            top: 0,
                            right: 0,
                            child: ClipPath(
                              clipper: TopRightTriangleClipper(),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    _imageForDiveType(event.diveType),
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Colors.black.withOpacity(0.6),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _labelForDiveType(event.diveType)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 4,
                                                color: Colors.black54,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 4),
                                        Icon(
                                          _iconForDiveType(event.diveType),
                                          color: Colors.white,
                                          size: 18,
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _imageForDiveType(DiveType type) {
    switch (type) {
      case DiveType.mer:
        return 'assets/pngs/mer.png';
      case DiveType.piscine:
        return 'assets/pngs/piscine.png';
      case DiveType.carriere:
        return 'assets/pngs/carriere.png';
      case DiveType.apero:
        return 'assets/pngs/apero.png';
      case DiveType.stage:
        return 'assets/pngs/stage.png';
      case DiveType.formation:
        return 'assets/pngs/formation.png';
      case DiveType.fosse:
        return 'assets/pngs/fosse.png';
    }
  }
}

/// ───── HELPERS ─────

IconData _iconForDiveType(DiveType type) {
  switch (type) {
    case DiveType.mer:
      return Icons.waves;
    case DiveType.fosse:
    case DiveType.piscine:
      return Icons.pool;
    case DiveType.carriere:
      return Icons.terrain;
    case DiveType.apero:
      return Icons.local_bar;
    case DiveType.formation:
      return Icons.school;
    case DiveType.stage:
      return Icons.workspace_premium;
  }
}

String _labelForDiveType(DiveType type) {
  switch (type) {
    case DiveType.mer:
      return 'Mer';
    case DiveType.fosse:
      return 'Fosse';
    case DiveType.piscine:
      return 'Piscine';
    case DiveType.carriere:
      return 'Carrière';
    case DiveType.apero:
      return 'Apéro';
    case DiveType.formation:
      return 'Formation';
    case DiveType.stage:
      return 'Stage';
  }
}

/// ───── INFOLINE ─────
class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// ───── MINI ACTION BUTTON ─────
class _MiniActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _MiniActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
