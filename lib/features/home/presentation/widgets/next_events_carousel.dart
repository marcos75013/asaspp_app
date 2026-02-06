import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/next_event_model.dart';
import '../pages/next_dive_card.dart';

class NextEventsCarousel extends StatefulWidget {
  const NextEventsCarousel({super.key});

  @override
  State<NextEventsCarousel> createState() => _NextEventsCarouselState();
}

class _NextEventsCarouselState extends State<NextEventsCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  final List<DiveType> _types = const [
    DiveType.fosse,
    DiveType.mer,
    DiveType.apero,
    DiveType.formation,
    DiveType.stage,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.99,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 16),

        /// 🎠 PAGEVIEW
        SizedBox(
          height: 180, // hauteur maîtrisée
          child: PageView.builder(
            controller: _pageController,
            itemCount: _types.length,
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
                    type: _types[index],
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
                        extra: _types[_currentIndex],
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
                      context.push('/covoiturage/join');
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
          children: List.generate(
            _types.length,
                (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 14 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

      ],
    );
  }
}
