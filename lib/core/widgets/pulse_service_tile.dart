import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum PulseService {
  quiz(
    'Quiz',
    'Teste tes connaissances',
    Icons.quiz_outlined,
    '/quiz',
    'QUIZ',
    Color(0xFF6934B6),
    Color(0xFFD8B8FF),
  ),
  library(
    'Bibliothèque',
    'Documents, liens et ressources',
    Icons.folder_outlined,
    '/documents',
    'DOCUMENT_LIBRARY',
    Color(0xFF00786B),
    Color(0xFF63DBC7),
  ),
  payments(
    'Paiements',
    'Liens de paiement de l’association',
    Icons.payment_outlined,
    '/payments',
    null,
    Color(0xFF0053D6),
    Color(0xFFA9C5FF),
  );

  const PulseService(
    this.label,
    this.description,
    this.icon,
    this.route,
    this.module,
    this.lightAccent,
    this.darkAccent,
  );

  final String label, description, route;
  final IconData icon;
  final String? module;
  final Color lightAccent, darkAccent;

  bool isAvailable(List<String> modules) =>
      module == null || modules.contains(module);
}

class PulseServiceTile extends StatelessWidget {
  final PulseService service;
  final bool compact;

  const PulseServiceTile({
    super.key,
    required this.service,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.brightness == Brightness.dark
        ? service.darkAccent
        : service.lightAccent;
    final badge = Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(service.icon, color: accent, size: 22),
    );
    void open() => context.push(service.route);
    return Card(
      margin: compact ? EdgeInsets.zero : const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: compact
          ? InkWell(
              onTap: open,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 4,
                ),
                child: Column(
                  children: [
                    badge,
                    const SizedBox(height: 8),
                    Text(
                      service.label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            )
          : ListTile(
              onTap: open,
              leading: badge,
              title: Text(service.label),
              subtitle: Text(service.description),
              trailing: const Icon(Icons.chevron_right),
            ),
    );
  }
}
