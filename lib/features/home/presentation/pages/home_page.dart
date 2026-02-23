import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../splash/presentation/widget/bubbles_layer.dart';
import '../../../user/demain/user_model.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/pages/user_profile_sheet.dart';
import '../widgets/next_events_carousel.dart';
import '../pages/welcome_section.dart';
import 'club_message_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openUserProfile(BuildContext context) {
    final user = context.read<UserCubit>().state;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserProfileSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

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
              onTap: () => _openUserProfile(context),
              child: BlocBuilder<UserCubit, UserModel>(
                builder: (context, user) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: "user-avatar",
                        child: const CircleAvatar(
                          radius: 26,
                          backgroundImage:
                          AssetImage('assets/jpgs/macron.jpg'),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.prenom,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
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
            color: Colors.black.withOpacity(0.18),
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

                  const SizedBox(height: 12),

                  const ClubMessageCard(),

                  const SizedBox(height: 20),

                  /// 📘 QUIZ RESTAURÉ
                  GestureDetector(
                    onTap: () {
                      context.go('/quiz');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.quiz,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "Quiz Plongée Plaisir 📘",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
