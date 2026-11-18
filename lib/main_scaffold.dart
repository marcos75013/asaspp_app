import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/config/api_config.dart';
import 'core/storage/auth_storage.dart';
import 'core/theme/app_colors.dart';
import 'features/annonces/presentation/pages/ads_page.dart';
import 'features/events/presentation/pages/about_us_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/gallery/presentation/pages/gallery_page.dart';
import 'features/home/data/services/mobile_event_api_service.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/messages/data/services/mobile_message_api_service.dart';
import 'features/messages/presentation/cubit/message_cubit.dart';
import 'features/context/cubit/context_cubit.dart';
import 'features/context/cubit/context_state.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  int _aboutVisit = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    final authStorage = AuthStorage();
    final apiClient = ApiClient(authStorage);

    _pages = [
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                HomeCubit(eventRepository: MobileEventApiService(apiClient))
                  ..loadEvents(),
          ),
          BlocProvider(
            create: (_) => MessageCubit(
              messageRepository: MobileMessageApiService(apiClient),
            )..loadMessages(),
          ),
        ],
        child: const HomePage(),
      ),
      AboutUsPage(key: ValueKey(_aboutVisit)),
      const GalleryPage(),
      const AdsPage(), // ⬅️ Petites annonces
    ];
  }

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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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

  Widget _activeIcon(String? imageUrl, IconData fallback) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Icon(fallback, size: 34, color: AppColors.primaryBlue);
    }
    return ClipOval(
      child: Image.network(
        const ApiConfig().resolveUrl(imageUrl),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stack) =>
            Icon(fallback, size: 34, color: AppColors.primaryBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ContextCubit, ContextState>(
      builder: (context, state) {
        final association = state.context?.currentAssociation;
        final modules = association?.modules ?? const <String>[];
        final tabs = [
          0,
          1,
          if (modules.contains('PHOTO_GALLERY')) 2,
          if (modules.contains('MARKETPLACE')) 3,
        ];
        final selected = tabs.contains(_currentIndex) ? _currentIndex : 0;
        const icons = [
          Icons.home,
          Icons.groups,
          Icons.photo_library,
          Icons.campaign,
        ];
        return Scaffold(
          extendBody: true,
          body: _pages[selected],
          bottomNavigationBar: SafeArea(
            bottom: true,
            child: CircleNavBar(
              height: 72,
              activeIndex: tabs.indexOf(selected),

              /// 👉 LE CERCLE affichera TOUJOURS ce plongeur
              activeIcons: [
                for (final index in tabs)
                  _activeIcon(association?.navigationImageUrl, icons[index]),
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
                  label: association?.associationName ?? 'Association',
                  active: _currentIndex == 1,
                ),
                if (tabs.contains(2))
                  _navItem(
                    icon: Icons.photo_library,
                    label: 'Galerie',
                    active: _currentIndex == 2,
                  ),
                if (tabs.contains(3))
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
                  _currentIndex = tabs[index];
                  if (_currentIndex == 1) {
                    _aboutVisit++;
                    _pages[1] = AboutUsPage(key: ValueKey(_aboutVisit));
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }
}
