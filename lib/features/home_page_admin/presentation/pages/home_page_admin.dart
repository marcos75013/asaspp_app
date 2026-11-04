import '../../../user/presentation/pages/user_profile_sheet.dart';
import '../../../../core/data/association_repository.dart';
import 'dart:ui';

import 'package:asaspp_app/features/user/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../user/demain/user_model.dart';
import '../../../context/cubit/context_cubit.dart';
import '../../../bo/bo_members.dart';
import '../../../bo/bo_events.dart';
import '../../../bo/bo_content.dart';
import '../../../bo/bo_quiz.dart';
import '../../../bo/bo_diving.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  String? _activityCode;
  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    if (!context.read<UserCubit>().isAdmin) return;
    try {
      final api = await repositoryOf(context).api();
      final association = await api.request(
        '/api/admin-association/association',
      );
      if (mounted)
        setState(() => _activityCode = association['activityCode'] as String?);
    } catch (_) {
      /* Other admin modules remain accessible; association page offers retry. */
    }
  }

  void _openUserProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserProfileSheet(user: context.read<UserCubit>().state),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<UserCubit>().isAdmin)
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Cet espace est réservé aux administrateurs.'),
        ),
      );
    final modules =
        context
            .watch<ContextCubit>()
            .state
            .context
            ?.currentAssociation
            ?.modules ??
        <String>[];
    final cards = adminCards
        .where((card) => card.module == null || modules.contains(card.module))
        .where((card) => card.page is! BoDiving || _activityCode == 'DIVING')
        .toList();
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

        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Espace Admin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
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
                          child: Icon(Icons.person),
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
              padding: EdgeInsets.zero,
              itemCount: cards.length,

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
                  child: _AdminCard(card: cards[index]),
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
                MaterialPageRoute(builder: (_) => widget.card.page),
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

                    border: Border.all(color: Colors.white.withOpacity(0.25)),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
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
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                    child: Image.asset(
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
                                  horizontal: 12,
                                ),
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
                            return Transform.scale(scale: value, child: child);
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
                                ),
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
  final String? module;

  const AdminCardModel({
    required this.title,
    required this.image,
    required this.page,
    required this.icon,
    this.module,
  });
}

/// DATA
final List<AdminCardModel> adminCards = [
  AdminCardModel(
    title: 'Mon association',
    icon: Icons.business,
    image: 'assets/pngs/logo_asaspp.png',
    page: const BoAssociation(),
  ),
  AdminCardModel(
    title: 'Suivi des membres',
    icon: Icons.group,
    image: 'assets/pngs/bg_mer.png',
    page: const BoMembers(),
  ),
  AdminCardModel(
    title: 'Alertes justificatifs',
    icon: Icons.fact_check_outlined,
    image: 'assets/pngs/bg_mer.png',
    page: const BoComplianceAlerts(),
  ),
  AdminCardModel(
    title: 'Événements',
    icon: Icons.event,
    image: 'assets/pngs/bg_mer.png',
    module: 'EVENTS',
    page: const BoEvents(),
  ),
  AdminCardModel(
    title: 'Présences',
    icon: Icons.how_to_reg,
    image: 'assets/pngs/bg_mer.png',
    module: 'EVENTS',
    page: const BoAttendanceStats(),
  ),
  AdminCardModel(
    title: 'Préparer les plongées',
    icon: Icons.scuba_diving,
    image: 'assets/pngs/bg_mer.png',
    module: 'EVENTS',
    page: const BoDiving(),
  ),
  AdminCardModel(
    title: 'Messages',
    icon: Icons.campaign,
    image: 'assets/pngs/bg_mer.png',
    module: 'CLUB_COMMUNICATION',
    page: const BoMessages(),
  ),
  AdminCardModel(
    title: 'Documents',
    icon: Icons.description,
    image: 'assets/pngs/bg_mer.png',
    module: 'DOCUMENT_LIBRARY',
    page: const BoDocuments(),
  ),
  AdminCardModel(
    title: 'Albums photo',
    icon: Icons.photo_library,
    image: 'assets/pngs/bg_mer.png',
    module: 'PHOTO_GALLERY',
    page: const BoAlbums(),
  ),
  AdminCardModel(
    title: 'Annonces',
    icon: Icons.campaign_outlined,
    image: 'assets/pngs/bg_mer.png',
    module: 'MARKETPLACE',
    page: const BoMarketplace(),
  ),
  AdminCardModel(
    title: 'Quiz et résultats',
    icon: Icons.quiz,
    image: 'assets/pngs/bg_mer.png',
    module: 'QUIZ',
    page: const BoQuizzes(),
  ),
];
