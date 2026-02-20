import 'dart:ui';
import 'package:flutter/material.dart';
import '../../demain/user_model.dart';

class UserProfileSheet extends StatelessWidget {
  final UserModel user;

  const UserProfileSheet({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                children: [
                  _dragHandle(),
                  const SizedBox(height: 30),

                  /// 🟢 AVATAR AVEC HALO
                  Center(
                    child: Hero(
                      tag: "user-avatar",
                      child: _GlowingAvatar(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      "${user.prenom} ${user.nom}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Center(
                    child: Text(
                      _roleLabel(user.role),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _profileTile(Icons.email, "Email", user.email),
                  _profileTile(Icons.phone, "Téléphone", user.telephone),
                  _profileTile(Icons.badge, "Licence FFESSM", user.licence),
                  _profileTile(Icons.diversity_3, "Club", user.club),
                  _profileTile(Icons.school, "Niveau", user.niveau),

                  const SizedBox(height: 20),

                  /// 🔵 COMPTEUR ANIMÉ
                  _DiveCounter(user.nombrePlongees),

                  const SizedBox(height: 30),

                  _actionButton("Modifier mon profil", Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  _actionButton("Se déconnecter", Colors.red.withOpacity(0.85)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 60,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () {},
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return "Administrateur";
      case UserRole.bureau:
        return "Membre du bureau";
      case UserRole.membre:
        return "Membre";
    }
  }
}


/// 🟢 HALO LUMINEUX ANIMÉ
class _GlowingAvatar extends StatefulWidget {
  @override
  State<_GlowingAvatar> createState() => _GlowingAvatarState();
}

class _GlowingAvatarState extends State<_GlowingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _glowAnimation =
        Tween<double>(begin: 4, end: 20).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (_, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.7),
                blurRadius: _glowAnimation.value,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 55,
            backgroundImage: AssetImage('assets/jpgs/macron.jpg'),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// 🔵 COMPTEUR ANIMÉ
class _DiveCounter extends StatelessWidget {
  final int dives;

  const _DiveCounter(this.dives);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Nombre de plongées",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: dives),
            duration: const Duration(seconds: 2),
            builder: (_, value, __) {
              return Text(
                "$value",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
