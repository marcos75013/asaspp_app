import 'dart:ui';

import 'package:asaspp_app/features/home_page_admin/presentation/pages/chinese_profile_form.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/pages/create_album_form.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/pages/create_event_form.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/pages/create_training_form.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/pages/payment_link_form.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/pages/write_message_form.dart';
import 'package:asaspp_app/features/user/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../user/demain/user_model.dart';
import 'document_form.dart';
import 'members_tracking_form.dart';

class HomePageAdmin extends StatelessWidget {
  const HomePageAdmin({super.key});

  void _openUserProfile(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      /// APPBAR
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.white,
        elevation: 2,

        /// bouton retour maintenant ici
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Espace Admin",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),

        centerTitle: true,

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _openUserProfile(context),
              child: BlocBuilder<UserCubit, UserModel>(
                builder: (context, user) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Hero(
                        tag: "user-avatar",
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage:
                          AssetImage('assets/jpgs/macron.jpg'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.prenom,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
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

      /// BODY
      body: Stack(
        children: [

          /// BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF001F3F),
                  Color(0xFF003B6F),
                  Color(0xFF005C97),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// LIGHT EFFECT
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          /// GRID
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 110, 16, 16),
            child: GridView.builder(
              itemCount: adminCards.length,

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),

              itemBuilder: (context, index) {
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + (index * 120)),
                  curve: Curves.easeOut,
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 40 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _AdminCard(card: adminCards[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class _AdminCard extends StatefulWidget {
  final AdminCardModel card;

  const _AdminCard({required this.card});

  @override
  State<_AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<_AdminCard> {
  double scale = 1;
  double hover = 0;

  void _press() => setState(() => scale = 0.95);
  void _release() => setState(() => scale = 1);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = -6),
      onExit: (_) => setState(() => hover = 0),

      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, hover, 0),

          child: GestureDetector(
            onTapDown: (_) => _press(),
            onTapCancel: _release,

            onTapUp: (_) {
              _release();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => widget.card.page,
                ),
              );
            },

            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),

                    color: Colors.white.withOpacity(0.15),

                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),

                  child: Stack(
                    children: [

                      Column(
                        children: [

                          /// IMAGE
                          Expanded(
                            flex: 3,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [

                                Hero(
                                  tag: widget.card.title,
                                  child: ClipRRect(
                                    borderRadius:
                                    const BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                    child: Image.network(
                                      widget.card.image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.35),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// TITLE
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Text(
                                  widget.card.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      /// BOUTON +
                      Positioned(
                        top: 100,
                        right: 64,
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.9, end: 1.1),
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: Color(0xFF005C97),
                            ),
                          ),
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// MODEL
class AdminCardModel {
  final String title;
  final String image;
  final Widget page;
  final IconData icon;

  const AdminCardModel({
    required this.title,
    required this.image,
    required this.page,
    required this.icon,
  });
}

/// DATA
final List<AdminCardModel> adminCards = [
  AdminCardModel(
    title: "Créer un événement",
    icon: Icons.event,
    image:
    "https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=600",
    page: const CreateEventForm(),
  ),
  AdminCardModel(
    title: "Créer un entraînement",
    icon: Icons.sports,
    image:
    "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=600",
    page: const CreateTrainingForm(),
  ),
  AdminCardModel(
    title: "Suivi des membres",
    icon: Icons.group,
    image:
    "https://images.unsplash.com/photo-1551434678-e076c223a692?w=600",
    page: const MembersTrackingForm(),
  ),
  AdminCardModel(
    title: "Message association",
    icon: Icons.campaign,
    image:
    "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=600",
    page: const WriteMessageForm(),
  ),
  AdminCardModel(
    title: "Lien de paiement",
    icon: Icons.payments,
    image:
    "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=600",
    page: const PaymentLinkForm(),
  ),
  AdminCardModel(
    title: "Documents utiles",
    icon: Icons.description,
    image:
    "https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=600",
    page: const DocumentForm(),
  ),
  AdminCardModel(
    title: "Profil chinois",
    icon: Icons.psychology,
    image:
    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600",
    page: const ChineseProfileForm(),
  ),
  AdminCardModel(
    title: "Album photo",
    icon: Icons.photo_library,
    image:
    "https://images.unsplash.com/photo-1492724441997-5dc865305da7?w=600",
    page: const CreateAlbumForm(),
  ),
];