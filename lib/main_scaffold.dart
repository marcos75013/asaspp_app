import 'core/widgets/pulse_appearance_menu.dart';
import 'core/widgets/member_avatar.dart';
import 'core/widgets/pulse_association_header.dart';
import 'core/widgets/pulse_section_title.dart';
import 'core/widgets/pulse_service_tile.dart';
import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/network/api_client.dart';
import 'core/config/api_config.dart';
import 'core/storage/auth_storage.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/pulse_theme.dart';
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

import 'features/context/data/models/association_role.dart';
import 'features/events/presentation/pages/about_us_page.dart';
import 'features/home/presentation/pages/club_message_card.dart';
import 'features/user/presentation/pages/user_profile_sheet.dart';

class MainScaffold extends StatefulWidget {
  final ApiClient? apiClient;

  const MainScaffold({super.key, this.apiClient});

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
    final apiClient = widget.apiClient ?? ApiClient(authStorage);

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
      BlocProvider(
        create: (_) =>
            MessageCubit(messageRepository: MobileMessageApiService(apiClient))
              ..loadMessages(),
        child: const _ClubTab(),
      ),
      const _ServicesTab(),
      const _ProfileTab(),
    ];
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool active,
  }) {
    final theme = Theme.of(context);
    final color = theme.brightness == Brightness.dark
        ? PulseTheme.build(Brightness.dark).colorScheme.onSurfaceVariant
        : AppColors.primaryBlue;

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
        const labels = ['Accueil', 'Agenda', 'Club', 'Services', 'Profil'];
        const icons = [
          Icons.home_outlined,
          Icons.calendar_month_outlined,
          Icons.groups_outlined,
          Icons.widgets_outlined,
          Icons.person_outline,
        ];
        return PopScope<Object?>(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _currentIndex != 0) {
              setState(() => _currentIndex = 0);
            }
          },
          child: Scaffold(
            extendBody: true,
            body: _pages[_currentIndex],
            bottomNavigationBar: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: Size(
                      constraints.maxWidth,
                      MediaQuery.sizeOf(context).height,
                    ),
                  ),
                  child: CircleNavBar(
                    height: 72,
                    activeIndex: _currentIndex,
                    activeIcons: [
                      for (var index = 0; index < labels.length; index++)
                        Semantics(
                          label: labels[index],
                          selected: true,
                          child: AssociationNavigationIcon(
                            imageUrl: association?.navigationImageUrl,
                            fallback: icons[index],
                          ),
                        ),
                    ],
                    inactiveIcons: [
                      for (var index = 0; index < labels.length; index++)
                        _navItem(
                          icon: icons[index],
                          label: labels[index],
                          active: false,
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
              ),
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
      return Center(
        child: Icon(fallback, size: 34, color: AppColors.primaryBlue),
      );
    }
    return ClipOval(
      child: Image.network(
        const ApiConfig().resolveUrl(imageUrl!),
        width: 72,
        height: 72,
        fit: BoxFit.contain,
        errorBuilder: (_, error, stack) => Center(
          child: Icon(fallback, size: 34, color: AppColors.primaryBlue),
        ),
      ),
    );
  }
}

void _openPage(BuildContext context, Widget page, {String? title}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => title == null
          ? page
          : Scaffold(
              appBar: AppBar(title: Text(title)),
              body: page,
            ),
    ),
  );
}

class _TabSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? header;
  const _TabSection({required this.title, required this.children, this.header});

  @override
  Widget build(BuildContext context) => Theme(
    data: PulseTheme.build(Theme.of(context).brightness),
    child: Scaffold(
      appBar: AppBar(
        title: header ?? Text(title),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: children,
      ),
    ),
  );
}

class _TabLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _TabLink(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _ClubTab extends StatelessWidget {
  const _ClubTab();

  @override
  Widget build(BuildContext context) {
    final mobileContext = context.watch<ContextCubit>().state.context;
    final association = mobileContext?.currentAssociation;
    final modules = association?.modules ?? const <String>[];
    return _TabSection(
      title: 'Club',
      header: PulseAssociationHeader(
        name: association?.associationName ?? 'MultiAsso',
        logoUrl: association?.logoUrl,
        onSwitch: mobileContext != null && mobileContext.associations.length > 1
            ? () => context.go('/association-selection', extra: mobileContext)
            : null,
      ),
      children: [
        if (modules.contains('CLUB_COMMUNICATION')) ...[
          const PulseSectionTitle('Actualités du club'),
          const ClubMessageCard(),
        ],
        const PulseSectionTitle('Découvrir le club'),
        _TabLink(
          Icons.groups_outlined,
          'Qui sommes-nous',
          () => _openPage(context, const AboutUsPage()),
        ),
        if (modules.contains('PHOTO_GALLERY'))
          _TabLink(
            Icons.photo_library_outlined,
            'Galerie',
            () => _openPage(context, const GalleryPage()),
          ),
        if (modules.contains('MARKETPLACE'))
          _TabLink(
            Icons.campaign_outlined,
            'Annonces',
            () => _openPage(context, const AdsPage(), title: 'Annonces'),
          ),
      ],
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context) {
    final mobileContext = context.watch<ContextCubit>().state.context;
    final association = mobileContext?.currentAssociation;
    final modules = association?.modules ?? const <String>[];
    return _TabSection(
      title: 'Services',
      header: PulseAssociationHeader(
        name: association?.associationName ?? 'MultiAsso',
        logoUrl: association?.logoUrl,
        onSwitch: mobileContext != null && mobileContext.associations.length > 1
            ? () => context.go('/association-selection', extra: mobileContext)
            : null,
      ),
      children: [
        const _ServicesIntro(),
        if (modules.contains('QUIZ') ||
            modules.contains('DOCUMENT_LIBRARY')) ...[
          const PulseSectionTitle('Apprendre et progresser'),
          for (final service in [PulseService.quiz, PulseService.library])
            if (service.isAvailable(modules))
              PulseServiceTile(service: service),
        ],
        const PulseSectionTitle('Vie pratique'),
        const PulseServiceTile(service: PulseService.payments),
      ],
    );
  }
}

class _ServicesIntro extends StatelessWidget {
  const _ServicesIntro();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.brightness == Brightness.dark
        ? PulseService.quiz.darkAccent
        : PulseService.quiz.lightAccent;
    final heading = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MES SERVICES',
          style: theme.textTheme.labelSmall?.copyWith(
            color: accent,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            text: 'À toi de ',
            style: heading,
            children: [
              TextSpan(
                text: 'jouer.',
                style: TextStyle(color: accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tous les outils de ton association.',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ContextCubit>();
    final profile = cubit.state.context;
    final association = profile?.currentAssociation;
    final user = profile?.user;
    final name = [user?.firstName ?? '', user?.lastName ?? ''].join(' ').trim();
    return _TabSection(
      title: 'Profil',
      header: PulseAssociationHeader(
        name: association?.associationName ?? 'MultiAsso',
        logoUrl: association?.logoUrl,
      ),
      children: [
        if (profile == null)
          _TabLink(Icons.refresh, 'Actualiser le profil', cubit.loadContext)
        else ...[
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    MemberAvatar(radius: 34, url: user?.avatarUrl, name: name),
                    const SizedBox(height: 10),
                    Text(
                      name.isEmpty ? 'Mon profil' : name,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (association != null) ...[
                      Text(
                        association.associationName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Chip(
                        label: Text(
                          association.role == AssociationRole.admin
                              ? 'Administrateur'
                              : 'Membre',
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const PulseSectionTitle('Mon compte'),
          _TabLink(Icons.person_outline, 'Mes informations', () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: UserProfileSheet(
                  user: profile.user,
                  association: association,
                ),
              ),
            );
          }),
          if (profile.associations.length > 1)
            _TabLink(
              Icons.swap_horiz,
              'Changer d’association',
              () => context.go('/association-selection', extra: profile),
            ),
          const PulseSectionTitle('Préférences'),
          const Card(child: PulseAppearanceMenu(tile: true)),
          if (association?.role == AssociationRole.admin) ...[
            const PulseSectionTitle('Administration'),
            _TabLink(
              Icons.admin_panel_settings_outlined,
              'Espace admin',
              () => context.go('/admin-home'),
            ),
          ],
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Se déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Se déconnecter'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  try {
                    await ApiClient(AuthStorage()).logout();
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Impossible de fermer la session. Réessaie.',
                          ),
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Se déconnecter'),
            ),
          ),
        ],
      ],
    );
  }
}
