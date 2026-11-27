import 'package:go_router/go_router.dart';
import '../../../../core/theme/pulse_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/member_avatar.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../context/cubit/context_cubit.dart';
import '../../../context/cubit/context_state.dart';
import '../../../messages/presentation/cubit/message_cubit.dart';
import '../../../user/presentation/pages/user_profile_sheet.dart';
import '../cubit/home_cubit.dart';
import '../widgets/next_events_carousel.dart';
import 'club_message_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _refreshContent(BuildContext context) async {
    await Future.wait([
      context.read<HomeCubit>().loadEvents(),
      context.read<MessageCubit>().loadMessages(),
    ]);
  }

  void _openUserProfile(BuildContext context, ContextState state) {
    final user = state.context?.user;
    final association = state.context?.currentAssociation;

    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<ContextCubit>(),
          child: UserProfileSheet(user: user, association: association),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContextCubit, ContextState>(
      builder: (context, contextState) {
        final user = contextState.context?.user;
        final association = contextState.context?.currentAssociation;
        final modules = association?.modules ?? const <String>[];

        final theme = PulseTheme.build(Theme.of(context).brightness);
        final name = user?.firstName.trim() ?? '';
        final logo = association?.logoUrl;
        final shortcuts = [
          if (modules.contains('QUIZ')) (Icons.quiz_outlined, 'Quiz', '/quiz'),
          if (modules.contains('DOCUMENT_LIBRARY'))
            (Icons.folder_outlined, 'Bibliothèque', '/documents'),
          (Icons.payment_outlined, 'Paiements', '/payments'),
        ];

        return Theme(
          data: theme,
          child: Scaffold(
            drawer: const AppDrawer(),
            appBar: AppBar(
              title: Row(
                children: [
                  if (logo != null && logo.isNotEmpty) ...[
                    Image.network(
                      const ApiConfig().resolveUrl(logo),
                      height: 32,
                      width: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.groups_outlined),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      association?.associationName ?? 'MultiAsso',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Mon profil',
                  onPressed: user == null
                      ? null
                      : () => _openUserProfile(context, contextState),
                  icon: MemberAvatar(
                    radius: 17,
                    url: user?.avatarUrl,
                    name: name,
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => _refreshContent(context),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    Text(
                      name.isEmpty ? 'Bienvenue' : 'Salut, $name !',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prêt pour la prochaine aventure ?',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (modules.contains('EVENTS')) ...[
                      const _HomeSectionTitle('Prochain rendez-vous'),
                      const NextEventsCarousel(),
                    ],
                    const _HomeSectionTitle('Accès rapides'),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns =
                            constraints.maxWidth < 320 ||
                                MediaQuery.textScalerOf(context).scale(14) > 20
                            ? 2
                            : 3;
                        const gap = 8.0;
                        final width =
                            (constraints.maxWidth - gap * (columns - 1)) /
                            columns;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final (icon, label, route) in shortcuts)
                              SizedBox(
                                width: width,
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () => context.push(route),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 4,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            icon,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            label,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    if (modules.contains('CLUB_COMMUNICATION')) ...[
                      const _HomeSectionTitle('La vie du club'),
                      const ClubMessageCard(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeSectionTitle extends StatelessWidget {
  final String label;
  const _HomeSectionTitle(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 10),
    child: Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}
