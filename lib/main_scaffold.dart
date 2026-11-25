import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/config/api_config.dart';
import 'core/storage/auth_storage.dart';
import 'core/theme/app_colors.dart';
import 'features/annonces/presentation/pages/ads_page.dart';
import 'features/events/presentation/pages/training_calendar_page.dart';
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
      const TrainingCalendarPage(),
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
          Icons.calendar_month,
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

              activeIcons: [
                for (final index in tabs)
                  AssociationNavigationIcon(
                    imageUrl: association?.navigationImageUrl,
                    fallback: icons[index],
                  ),
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
                  label: 'Calendrier',
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
                });
              },
            ),
          ),
        );
      },
    );
  }
}

class AssociationNavigationIcon extends StatelessWidget {
  final String? imageUrl;
  final IconData fallback;
  const AssociationNavigationIcon({
    super.key,
    this.imageUrl,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return Icon(fallback, size: 34, color: AppColors.primaryBlue);
    }
    return ClipOval(
      child: Image.network(
        const ApiConfig().resolveUrl(imageUrl!),
        width: 72,
        height: 72,
        fit: BoxFit.contain,
        errorBuilder: (_, error, stack) =>
            Icon(fallback, size: 34, color: AppColors.primaryBlue),
      ),
    );
  }
}
