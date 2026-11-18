import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/context/cubit/context_cubit.dart';
import '../../features/context/data/models/association_role.dart';
import '../config/api_config.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final mobileContext = context.watch<ContextCubit>().state.context;
    final association = mobileContext?.currentAssociation;
    final modules = association?.modules ?? const <String>[];
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
                  if (association?.logoUrl?.isNotEmpty == true)
                    Image.network(
                      const ApiConfig().resolveUrl(association!.logoUrl!),
                      height: 50,
                      width: 50,
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stack) =>
                          const Icon(Icons.groups, color: Colors.white),
                    )
                  else
                    const Icon(Icons.groups, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      association?.associationName ?? 'Association',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white24),
            if (association?.role == AssociationRole.admin)
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

            if (mobileContext != null && mobileContext.associations.length > 1)
              _DrawerItem(
                icon: Icons.swap_horiz,
                title: 'Changer d’association',
                onTap: () =>
                    context.go('/association-selection', extra: mobileContext),
              ),

            if (modules.contains('DOCUMENT_LIBRARY'))
              _DrawerItem(
                icon: Icons.folder_open,
                title: "Bibliothèque",
                onTap: () {
                  context.push('/documents');
                },
              ),

            if (modules.contains('QUIZ'))
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
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
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
