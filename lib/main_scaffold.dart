import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

import 'core/theme/app_colors.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/events/presentation/pages/events_page.dart';
import 'features/gallery/presentation/pages/gallery_page.dart';
import 'features/planning/presentation/pages/ads_page.dart'; // ⬅️ nouvelle page

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    EventsPage(),
    GalleryPage(),
    AdsPage(), // ⬅️ Petites annonces
  ];

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool active,
  }) {
    final color = AppColors.primaryBlue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 14), // un peu moins d’espace
        Icon(
          icon,
          size: active ? 26 : 24, // ⬅️ ICÔNES PLUS GRANDES
          color: color,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: active ? 9 : 13, // ⬅️ TITRES PLUS GRANDS
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  /// 🧑‍🤿 Icône UNIQUE (toujours la même)
  Widget _diverIcon() {
    return Image.asset(
      'assets/pngs/plongeur1.png',
      width: 80,
      height: 80,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: CircleNavBar(
          height: 72,
          activeIndex: _currentIndex,

          /// 👉 LE CERCLE affichera TOUJOURS ce plongeur
          activeIcons: [
            _diverIcon(),
            _diverIcon(),
            _diverIcon(),
            _diverIcon(),
          ],

          /// 👉 Icônes + labels
          inactiveIcons: [
            _navItem(
              icon: Icons.home,
              label: 'Accueil',
              active: _currentIndex == 0,
            ),
            _navItem(
              icon: Icons.event,
              label: 'Asaspp',
              active: _currentIndex == 1,
            ),
            _navItem(
              icon: Icons.photo_library,
              label: 'Galerie',
              active: _currentIndex == 2,
            ),
            _navItem(
              icon: Icons.campaign, // ⬅️ icône annonces
              label: 'Annonces',
              active: _currentIndex == 3,
            ),
          ],

          /// 🎨 STYLE
          color: theme.colorScheme.surface.withValues(alpha: 0.95),
          circleColor: AppColors.background,
          circleWidth: 72,
          elevation: 12,
          shadowColor: Colors.black26,

          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
