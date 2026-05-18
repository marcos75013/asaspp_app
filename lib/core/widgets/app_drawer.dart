import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF001F2D),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔵 HEADER AVEC LOGO
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Image.asset(
                    "assets/pngs/logo_asaspp.png",
                    height: 50,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "ASASPP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white24),
            _DrawerItem(
              icon: Icons.settings_input_svideo_sharp,
              title: "ESPACE ADMIN",
              onTap: () {
                context.go('/admin-home');
              },
            ),
            const Divider(color: Colors.white24),

            /// MENU ITEMS
            _DrawerItem(
              icon: Icons.home,
              title: "Accueil",
              onTap: () {
                context.go('/home');
              },
            ),

            _DrawerItem(
              icon: Icons.payment,
              title: "Paiement",
              onTap: () {
                context.push('/payments');
              },
            ),

            _DrawerItem(
              icon: Icons.folder_open,
              title: "Bibliothèque",
              onTap: () {
                context.push('/documents');
              },
            ),

            _DrawerItem(
              icon: Icons.quiz,
              title: "Quiz",
              onTap: () {
                context.push('/quiz');
              },
            ),

            const Spacer(),

            const Divider(color: Colors.white24),

            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Version 1.0.0",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // ferme le drawer
        onTap();
      },
    );
  }
}