import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/association_repository.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/next_dive_card.dart';

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
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state.error != null && state.nextEvents.isNotEmpty)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
      },
      builder: (context, state) {
        final events = state.nextEvents.values.toList();
        if (state.loading || events.isEmpty)
          return DataStatus(
            loading: state.loading,
            error: state.error,
            empty: 'Aucune sortie publiée pour le moment.',
            reload: () => context.read<HomeCubit>().loadEvents(),
          );
        final selected = _currentIndex.clamp(0, events.length - 1);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            /// 🎠 PAGEVIEW
            SizedBox(
              height: 240 * MediaQuery.textScalerOf(context).scale(14) / 14,
              child: PageView.builder(
                controller: _pageController,
                itemCount: events.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final isActive = index == _currentIndex;

                  return AnimatedPadding(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: isActive ? 4 : 10,
                    ),
                    child: SizedBox.expand(
                      // 🔥 SUPPRIME L’ESPACE VIDE
                      child: NextDiveCard(
                        eventId: events[index].id,
                        highlighted: isActive,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            /// 🚗 ACTIONS (lié à l’événement actif)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.88,
                child: Row(
                  children: [
                    /// 🚗 COVOITURAGE
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push(
                            '/covoiturage/create',
                            extra: events[selected],
                          );
                        },

                        // icon: const Icon(Icons.local_fire_department),
                        label: const Text('Créer un covoiturage'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// 📍 DEPART / RDV
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push(
                            '/covoiturage/join',
                            extra: events[selected],
                          );
                        },

                        // icon: const Icon(Icons.place_outlined),
                        label: const Text("je m'y infiltre"),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),

                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// 🔵 INDICATOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(events.length.clamp(0, 7), (offset) {
                final start = (_currentIndex - 3).clamp(
                  0,
                  (events.length - 7).clamp(0, events.length),
                );
                final index = start + offset;
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 14 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white,
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
}
