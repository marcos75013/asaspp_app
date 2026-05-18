import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/feature_tile.dart';
import '../../../paiement/presentation/widgets/payment_floating_button.dart';
import '../../../paiement/presentation/widgets/payment_home_card.dart';
import '../../../splash/presentation/widget/bubbles_layer.dart';
import '../../../user/demain/user_model.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/pages/user_profile_sheet.dart';
import '../../../ducumentslib/presentation/widgets/documents_library_card.dart';
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
                          color: Colors.black,
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


                  Center(child: const PaymentActionButton()),

                  const ClubMessageCard(),

                  const SizedBox(height: 16),

                  FeatureTile(
                    title: "Quiz Plongée Plaisir",
                    subtitle: "Teste tes connaissances",
                    icon: Icons.quiz,
                    gradient: [
                      const Color(0xFF0061FF),
                      const Color(0xFF60EFFF),
                    ],
                    route: "/quiz",
                  ),

                  SizedBox(height: 20),

                  FeatureTile(
                    title: "Bibliothèque Plongée",
                    subtitle: "Documents & Liens utiles",
                    icon: Icons.folder_open,
                    gradient: [
                      const Color(0xFF11998E),
                      const Color(0xFF38EF7D),
                    ],
                    route: "/documents",
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
