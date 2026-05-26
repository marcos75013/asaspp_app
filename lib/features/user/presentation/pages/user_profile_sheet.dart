import 'package:asaspp_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../demain/user_model.dart';

class UserProfileSheet extends StatelessWidget {
  final UserModel user;

  const UserProfileSheet({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),

              /// 🎨 Glass effect optimisé (sans blur runtime)
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.96),
                  Colors.white.withOpacity(0.88),
                ],
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
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
                    child: const _GlowingAvatar(),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    "${user.prenom} ${user.nom}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Center(
                  child: Text(
                    _roleLabel(user.role),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),

                const SizedBox(height: 30),

                _profileTile(Icons.email, "Email", user.email),
                _profileTile(Icons.phone, "Téléphone", user.telephone),
                _profileTile(Icons.badge, "Licence FFESSM", user.licence),
                _profileTile(Icons.diversity_3, "Club", user.club),
                _profileTile(Icons.school, "Niveau", user.niveau),

                const SizedBox(height: 20),

                _DiveCounter(user.nombrePlongees),

                const SizedBox(height: 30),

                _actionButton(
                  "Modifier mon profil",
                  Colors.blueAccent.withOpacity(0.9),
                  () {},
                ),
                const SizedBox(height: 12),
                _actionButton(
  'Se déconnecter',
  Colors.red,
  () async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await context.read<AuthCubit>().logout();

    if (!context.mounted) return;

    context.go('/login');
  },
)
              ],
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
          color: Colors.black.withOpacity(0.2),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueGrey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 4,
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white)),
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

class _GlowingAvatar extends StatefulWidget {
  const _GlowingAvatar();

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 4, end: 16).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.4),
                blurRadius: _glowAnimation.value,
                spreadRadius: 1,
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

class _DiveCounter extends StatefulWidget {
  final int dives;

  const _DiveCounter(this.dives);

  @override
  State<_DiveCounter> createState() => _DiveCounterState();
}

class _DiveCounterState extends State<_DiveCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = IntTween(
      begin: 0,
      end: widget.dives,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Nombre de plongées",
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 10),

          /// 🔥 Seul le texte est animé
          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) {
              return Text(
                "${_animation.value}",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
