import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../events/presentation/pages/training_detail_page.dart';
import '../../data/models/next_event_model.dart';
import '../cubit/home_cubit.dart';
import '../widgets/triangle_clipper.dart';

class NextDiveCard extends StatefulWidget {
  final NextEventModel event;
  final bool highlighted;

  const NextDiveCard({
    super.key,
    required this.event,
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

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

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
    final event = widget.event;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  color: colors.surface,
                  border: Border.all(
                    color: widget.highlighted
                        ? colors.primary
                        : colors.outlineVariant,
                  ),
                ),
                child: Stack(
                  children: [
                    /// ───── CONTENU ─────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (event.site.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            event.site,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        _InfoLine(icon: Icons.calendar_today, text: event.date),
                        const SizedBox(height: 4),
                        _InfoLine(icon: Icons.access_time, text: event.time),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TrainingDetailPage(
                                training: event,
                                apiClient: ApiClient(AuthStorage()),
                                isEvent: true,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.group_outlined, size: 18),
                          label: Text('${event.goingCount} participant(s)'),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniActionButton(
                                label: 'Je viens',
                                icon: Icons.check,
                                color: Colors.green,
                                selected:
                                    event.participation ==
                                    ParticipationStatus.going,
                                onTap: () =>
                                    context.read<HomeCubit>().setParticipation(
                                      event.id,
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
                                selected:
                                    event.participation ==
                                    ParticipationStatus.maybe,
                                onTap: () =>
                                    context.read<HomeCubit>().setParticipation(
                                      event.id,
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
                                selected:
                                    event.participation ==
                                    ParticipationStatus.notGoing,
                                onTap: () =>
                                    context.read<HomeCubit>().setParticipation(
                                      event.id,
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
                            if (event.categoryImageUrl?.trim().isNotEmpty ==
                                true)
                              Image.network(
                                const ApiConfig().resolveUrl(
                                  event.categoryImageUrl!,
                                ),
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _fallbackImage(event.diveType),
                              )
                            else
                              _fallbackImage(event.diveType),
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: SizedBox(
                                width: 80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      (event.category.isNotEmpty
                                              ? event.category
                                              : 'Événement')
                                          .toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage(DiveType type) {
    if (type == DiveType.autre) {
      return Container(width: 96, height: 96, color: const Color(0xFF34527A));
    }
    return Image.asset(
      _imageForDiveType(type),
      width: 96,
      height: 96,
      fit: BoxFit.cover,
    );
  }

  String _imageForDiveType(DiveType type) {
    switch (type) {
      case DiveType.autre:
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
    case DiveType.autre:
      return Icons.event;
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

/// ───── INFOLINE ─────
class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
          color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
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
