import 'package:flutter/material.dart';

import '../../../context/data/models/association_role.dart';
import '../../../context/data/models/mobile_association_model.dart';
import '../../../context/data/models/mobile_user_model.dart';

class UserProfileSheet extends StatelessWidget {
  final MobileUserModel user;
  final MobileAssociationModel? association;

  const UserProfileSheet({
    super.key,
    required this.user,
    this.association,
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
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
                const Center(
                  child: Hero(
                    tag: "user-avatar",
                    child: _GlowingAvatar(),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "${user.firstName} ${user.lastName}",
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
                    _roleLabel(association?.role),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _profileTile(Icons.email, "Email", user.email),
                _profileTile(
                  Icons.phone,
                  "Téléphone",
                  user.phone ?? "Non renseigné",
                ),
                _profileTile(
                  Icons.diversity_3,
                  "Association active",
                  association?.associationName ?? "Non renseignée",
                ),
                _profileTile(
                  Icons.verified_user,
                  "Rôle",
                  _roleLabel(association?.role),
                ),
                const SizedBox(height: 20),
                _modulesCard(association?.modules ?? []),
                const SizedBox(height: 30),
                _actionButton(
                  "Modifier mon profil",
                  Colors.blueAccent.withOpacity(0.9),
                ),
                const SizedBox(height: 12),
                _actionButton(
                  "Se déconnecter",
                  Colors.red.withOpacity(0.85),
                ),
                const SizedBox(height: 40),
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
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
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
            )
          ],
        ),
      ),
    );
  }

  Widget _modulesCard(List<String> modules) {
    if (modules.isEmpty) {
      return _profileTile(
        Icons.apps,
        "Modules",
        "Aucun module disponible",
      );
    }

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.apps, color: Colors.blueGrey),
              SizedBox(width: 16),
              Text(
                "Modules disponibles",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: modules.map((module) {
              return Chip(
                label: Text(
                  module,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
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
        elevation: 4,
      ),
      onPressed: () {},
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  String _roleLabel(AssociationRole? role) {
    switch (role) {
      case AssociationRole.admin:
        return "Administrateur";
      case AssociationRole.member:
        return "Membre";
      default:
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

    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _glowAnimation =
        Tween<double>(begin: 4, end: 16).animate(_controller);
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