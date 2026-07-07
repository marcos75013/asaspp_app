import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/feature_tile.dart';
import '../../../context/cubit/context_cubit.dart';
import '../../../context/cubit/context_state.dart';
import '../../../ducumentslib/presentation/widgets/documents_library_card.dart';
import '../../../paiement/presentation/widgets/payment_home_card.dart';
import '../../../splash/presentation/widget/bubbles_layer.dart';
import '../../../user/presentation/pages/user_profile_sheet.dart';
import '../pages/welcome_section.dart';
import '../widgets/next_events_carousel.dart';
import 'club_message_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String _baseUrl = 'http://192.168.1.36:8080';

  void _openUserProfile(BuildContext context, ContextState state) {
    final user = state.context?.user;
    final association = state.context?.currentAssociation;

    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return UserProfileSheet(
          user: user,
          association: association,
        );
      },
    );
  }

  ImageProvider _avatarProvider(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const AssetImage('assets/jpgs/macron.jpg');
    }

    if (avatarUrl.startsWith('http')) {
      return NetworkImage(avatarUrl);
    }

    return NetworkImage('$_baseUrl$avatarUrl');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContextCubit, ContextState>(
      builder: (context, contextState) {
        final user = contextState.context?.user;

        return Scaffold(
          extendBodyBehindAppBar: true,
          drawer: const AppDrawer(),
          appBar: AppBar(
            toolbarHeight: 110,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Image.asset(
              'assets/pngs/logo_asaspp.png',
              height: 120,
            ),
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
                        child: CircleAvatar(
                          radius: 26,
                          backgroundImage: _avatarProvider(user?.avatarUrl),
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
              Image.asset(
                'assets/pngs/bg_mer.png',
                fit: BoxFit.cover,
              ),
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const WelcomeSection(),
                      const SizedBox(height: 12),
                      const NextEventsCarousel(),
                      const ClubMessageCard(),
                      const SizedBox(height: 6),
                      const PaymentHomeCard(),
                      const SizedBox(height: 2),
                      FeatureTile(
                        title: "Quiz Plongée",
                        subtitle: "Teste tes connaissances",
                        icon: Icons.quiz,
                        gradient: [
                          Color(0xFF0061FF),
                          Color(0xFF60EFFF),
                        ],
                        route: "/quiz",
                      ),
                      const SizedBox(height: 2),
                      const DocumentsLibraryCard(),
                      const SizedBox(height: 46),
                    ],
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