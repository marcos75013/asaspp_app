import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../pages/next_dive_card.dart';
import '../../../context/cubit/context_cubit.dart';

class NextEventsCarousel extends StatefulWidget {
  const NextEventsCarousel({super.key});

  @override
  State<NextEventsCarousel> createState() => _NextEventsCarouselState();
}

class _NextEventsCarouselState extends State<NextEventsCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.99);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.loading ||
            state.status == HomeStatus.initial) {
          return const _EventFeedback(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        if (state.status == HomeStatus.error) {
          return _EventFeedback(
            child: TextButton.icon(
              onPressed: context.read<HomeCubit>().loadEvents,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer de charger les événements'),
            ),
          );
        }

        final events = state.nextEvents;
        if (events.isEmpty) {
          return const _EventFeedback(
            child: Text('Aucun événement à venir pour le moment.'),
          );
        }

        final currentIndex = _currentIndex.clamp(0, events.length - 1);
        final currentEvent = events[currentIndex];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height:
                  320 +
                  (MediaQuery.textScalerOf(context).scale(16) - 16).clamp(
                        0,
                        double.infinity,
                      ) *
                      6,
              child: PageView.builder(
                controller: _pageController,
                itemCount: events.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final isActive = index == currentIndex;

                  return AnimatedPadding(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: isActive ? 4 : 10,
                    ),
                    child: SizedBox.expand(
                      child: NextDiveCard(
                        event: events[index],
                        highlighted: isActive,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (context
                    .read<ContextCubit>()
                    .state
                    .context
                    ?.currentAssociation
                    ?.modules
                    .contains('CARPOOLING') ==
                true)
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.88,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.push(
                              '/covoiturage/create',
                              extra: currentEvent,
                            );
                          },
                          label: const Text('Créer un covoiturage'),
                          style: _carpoolButtonStyle(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/covoiturage/join',
                            extra: currentEvent,
                          ),
                          label: const Text("je m'y infiltre"),
                          style: _carpoolButtonStyle(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(events.length, (index) {
                final isActive = index == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 14 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  ButtonStyle _carpoolButtonStyle() {
    return OutlinedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      padding: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _EventFeedback extends StatelessWidget {
  final Widget child;

  const _EventFeedback({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 216, child: Center(child: child));
  }
}
