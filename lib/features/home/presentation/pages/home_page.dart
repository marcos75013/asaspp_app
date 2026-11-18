import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/member_avatar.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/feature_tile.dart';
import '../../../context/cubit/context_cubit.dart';
import '../../../context/cubit/context_state.dart';
import '../../../ducumentslib/presentation/widgets/documents_library_card.dart';
import '../../../messages/presentation/cubit/message_cubit.dart';
import '../../../splash/presentation/widget/bubbles_layer.dart';
import '../../../user/presentation/pages/user_profile_sheet.dart';
import '../cubit/home_cubit.dart';
import '../pages/welcome_section.dart';
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

        return Scaffold(
          extendBodyBehindAppBar: true,
          drawer: const AppDrawer(),
          appBar: AppBar(
            toolbarHeight: 110,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: association?.logoUrl?.isNotEmpty == true
                ? Image.network(
                    const ApiConfig().resolveUrl(association!.logoUrl!),
                    height: 100,
                    errorBuilder: (_, error, stack) =>
                        Text(association.associationName),
                  )
                : Text(association?.associationName ?? 'MultiAsso'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 12),
                child: GestureDetector(
                  onTap: () => _openUserProfile(context, contextState),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: "user-avatar",
                        child: MemberAvatar(
                          radius: 26,
                          url: user?.avatarUrl,
                          name:
                              '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.firstName ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/pngs/bg_mer.png', fit: BoxFit.cover),
              const BubblesLayer(),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0.08),
                      Color.fromRGBO(0, 0, 0, 0.22),
                      Color.fromRGBO(0, 0, 0, 0.35),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: () => _refreshContent(context),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const WelcomeSection(),
                        const SizedBox(height: 12),
                        if (modules.contains('EVENTS'))
                          const NextEventsCarousel(),
                        if (modules.contains('CLUB_COMMUNICATION'))
                          const ClubMessageCard(),
                        if (modules.contains('QUIZ')) ...[
                          const SizedBox(height: 2),
                          FeatureTile(
                            title: 'Quiz',
                            subtitle: 'Teste tes connaissances',
                            icon: Icons.quiz,
                            gradient: const [
                              Color(0xFF0061FF),
                              Color(0xFF60EFFF),
                            ],
                            route: '/quiz',
                          ),
                        ],
                        if (modules.contains('DOCUMENT_LIBRARY')) ...[
                          const SizedBox(height: 2),
                          const DocumentsLibraryCard(),
                        ],
                        const SizedBox(height: 46),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
