import 'package:flutter/material.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../data/models/association_about.dart';
import '../../data/services/association_about_repository.dart';
import '../../../user/data/profile_updates.dart';

class AboutUsPage extends StatefulWidget {
  final AssociationAboutRepository? repository;
  const AboutUsPage({super.key, this.repository});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  late final AssociationAboutRepository _repository =
      widget.repository ?? AssociationAboutApiService(ApiClient(AuthStorage()));
  AssociationAbout? _about;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    profileUpdates.addListener(_load);
  }

  @override
  void dispose() {
    profileUpdates.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _about = null;
    });
    try {
      final about = await _repository.load();
      if (mounted) setState(() => _about = about);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Impossible de charger la présentation.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static IconData? _icon(String value) => switch (value) {
    'HEART' => Icons.favorite,
    'GROUP' => Icons.groups,
    'SHIELD' => Icons.shield,
    'STAR' => Icons.star,
    'LEAF' => Icons.eco,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final about = _about;
    final presentation = about?.presentation;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/pngs/bg_mer.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade900.withValues(alpha: .4),
                    Colors.black.withValues(alpha: .65),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              presentation?.title ?? 'Qui sommes-nous',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (about != null)
                              Text(
                                about.associationName,
                                style: const TextStyle(color: Colors.white70),
                              ),
                          ],
                        ),
                      ),
                      if (about?.logoUrl case final String url
                          when url.isNotEmpty)
                        Image.network(
                          const ApiConfig().resolveUrl(url),
                          height: 70,
                          errorBuilder: (_, error, stack) =>
                              const SizedBox.shrink(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_loading)
                    const Center(child: CircularProgressIndicator()),
                  if (_error != null)
                    _GlassCard(
                      child: Column(
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: _load,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  if (!_loading && _error == null && about != null) ...[
                    if (presentation!.configured &&
                        presentation.introduction.isNotEmpty) ...[
                      _GlassCard(
                        child: Text(
                          presentation.introduction,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (!presentation.configured) ...[
                      const _GlassCard(
                        child: Text(
                          'La présentation de cette association n’est pas encore disponible.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (presentation.configured &&
                        presentation.values.isNotEmpty) ...[
                      _GlassCard(
                        child: Column(
                          children: [
                            for (final value in presentation.values)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_icon(value.icon) case final icon?) ...[
                                      Icon(icon, color: Colors.white),
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            value.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            value.text,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (presentation.configured &&
                        presentation.activities.isNotEmpty) ...[
                      _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ce que nous faisons',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (final activity in presentation.activities)
                              Text(
                                '• $activity',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.6,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (about.positions.isNotEmpty)
                      _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Organigramme',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                            const SizedBox(height: 16),
                            for (final position in about.orderedPositions)
                              _PositionTile(
                                position: position,
                                member: about.members[position.membershipId],
                              ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionTile extends StatelessWidget {
  final OrganizationPosition position;
  final OrganizationMember? member;
  const _PositionTile({required this.position, this.member});

  @override
  Widget build(BuildContext context) {
    final avatar = member?.avatarUrl;
    return Padding(
      padding: EdgeInsets.only(
        left: (position.depth * 18).toDouble(),
        bottom: 10,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              foregroundImage: avatar == null
                  ? null
                  : NetworkImage(const ApiConfig().resolveUrl(avatar)),
              onForegroundImageError: avatar == null ? null : (error, stack) {},
              child: member == null
                  ? const Icon(Icons.person_outline)
                  : Text(_initials(member!.name)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    position.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (member != null) Text(member!.name),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: .2),
          Colors.white.withValues(alpha: .15),
        ],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: .25)),
    ),
    child: child,
  );
}
