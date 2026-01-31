import 'package:flutter/material.dart';

import '../../../splash/presentation/widget/bubbles_layer.dart';
import '../widgets/next_events_carousel.dart';
import '../pages/welcome_section.dart';
import 'club_message_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      /// 🧭 APP BAR TRANSPARENTE
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Image.asset(
          'assets/pngs/logo_asaspp.png',
          height: 120,
        ),
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🌊 IMAGE DE FOND
          Image.asset(
            'assets/pngs/bg_mer.png',
            fit: BoxFit.cover,
          ),

          /// 🫧 BULLES ANIMÉES
          const BubblesLayer(),

          /// 🌑 VOILE DE LISIBILITÉ
          Container(
            color: Colors.black.withOpacity(0.18),
          ),

          /// 📜 CONTENU
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  /// 👋 BIENVENUE
                  const WelcomeSection(),

                  const SizedBox(height: 12), // ⬅️ réduit

                  /// 🎠 PROCHAINS ÉVÉNEMENTS
                  const NextEventsCarousel(),

                  const SizedBox(height: 4), // ⬅️ réduit

                  /// 📣 MESSAGE DU CLUB
                  const ClubMessageCard(),

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
