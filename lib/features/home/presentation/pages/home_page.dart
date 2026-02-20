import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

                  /// 🧠 NOUVELLE CARD QUIZ
                  GestureDetector(
                    onTap: () {
                      context.go('/quiz');
                    },
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
