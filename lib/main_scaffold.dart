import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/context/cubit/context_cubit.dart';
import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

import 'core/theme/app_colors.dart';
import 'features/annonces/presentation/pages/ads_page.dart';
import 'features/events/presentation/pages/about_us_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/gallery/presentation/pages/gallery_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: active ? 9 : 13, // ⬅️ TITRES PLUS GRANDS
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: color,
              letterSpacing: 0.3,
            ),
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
    final modules =
        context
            .watch<ContextCubit>()
            .state
            .context
            ?.currentAssociation
            ?.modules ??
        <String>[];
    final tabs = <({Widget page, IconData icon, String label})>[
      (page: const HomePage(), icon: Icons.home, label: 'Accueil'),
      (page: const AboutUsPage(), icon: Icons.event, label: 'Asaspp'),
      if (modules.contains('PHOTO_GALLERY'))
        (
          page: const GalleryPage(),
          icon: Icons.photo_library,
          label: 'Galerie',
        ),
      if (modules.contains('MARKETPLACE'))
        (page: const AdsPage(), icon: Icons.campaign, label: 'Annonces'),
    ];
    final selected = _currentIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      extendBody: true,
      body: tabs[selected].page,
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: CircleNavBar(
          height: 72,
          activeIndex: selected,

          /// 👉 LE CERCLE affichera TOUJOURS ce plongeur
          activeIcons: [for (var i = 0; i < tabs.length; i++) _diverIcon()],
          inactiveIcons: [
            for (var i = 0; i < tabs.length; i++)
              _navItem(
                icon: tabs[i].icon,
                label: tabs[i].label,
                active: selected == i,
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
