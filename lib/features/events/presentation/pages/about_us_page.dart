import 'dart:ui';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          /// 🌊 BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/pngs/bg_mer.png',
              fit: BoxFit.cover,
            ),
          ),

          /// 🌫️ OVERLAY GRADIENT
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade900.withOpacity(0.4),
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
          ),

          /// 📜 CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🧭 HEADER
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          'Qui sommes-nous',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/pngs/logo_asaspp.png',
                        height: 70,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// 🧊 INTRO
                  _GlassCard(
                    child: Text(
                      'Une association de passionnés de plongée, '
                          'unis par l’envie de partager des moments uniques '
                          'sous l’eau et hors de l’eau.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ⭐ VALUES
                  _GlassCard(
                    child: Column(
                      children: const [
                        _GlassValue(
                          icon: Icons.favorite,
                          title: 'Passion',
                          text: 'La plongée est au cœur de notre ADN.',
                        ),
                        _GlassValue(
                          icon: Icons.groups,
                          title: 'Esprit de groupe',
                          text: 'Convivialité, entraide et bonne humeur.',
                        ),
                        _GlassValue(
                          icon: Icons.shield,
                          title: 'Sécurité',
                          text: 'Encadrement sérieux et respect des règles.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// 🤿 ACTIVITIES
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ce que nous faisons',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Sorties en mer\n'
                              '• Entraînements piscine\n'
                              '• Formations & niveaux\n'
                              '• Événements et apéros club',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// 🏛 ORGANIGRAMME
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Organigramme',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _OrgButton(
                                label: 'Direction',
                                onTap: () => _openOrgModal(
                                  context,
                                  title: 'Direction',
                                  members: _directionMembers,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _OrgButton(
                                label: 'Moniteurs',
                                onTap: () => _openOrgModal(
                                  context,
                                  title: 'Moniteurs',
                                  members: _moniteurMembers,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

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

/// ================= MODAL =================

void _openOrgModal(
    BuildContext context, {
      required String title,
      required List<_OrgMember> members,
    }) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.9,
        builder: (context, controller) {
          return ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                color: Colors.white.withOpacity(0.92),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.all(16),
                        itemCount: members.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                        itemBuilder: (_, index) =>
                            _MemberTile(member: members[index]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

/// ================= DATA =================

class _OrgMember {
  final String name;
  final String role;
  final String imagePath;
  final int? divesCount;

  const _OrgMember({
    required this.name,
    required this.role,
    required this.imagePath,
    this.divesCount,
  });
}

/// Direction → pas de badge
const _directionMembers = [
  _OrgMember(
    name: 'Jean Dupont',
    role: 'Président',
    imagePath: 'assets/jpgs/macron.jpg',
  ),
  _OrgMember(
    name: 'Marie Martin',
    role: 'Secrétaire',
    imagePath: 'assets/jpgs/macron.jpg',
  ),
];

/// Moniteurs → badges poissons
const _moniteurMembers = [
  _OrgMember(
    name: 'Sophie Bernard',
    role: 'Monitrice E3',
    imagePath: 'assets/jpgs/macron.jpg',
    divesCount: 15,
  ),
  _OrgMember(
    name: 'Lucas Petit',
    role: 'Moniteur E4',
    imagePath: 'assets/jpgs/macron.jpg',
    divesCount: 25,
  ),
  _OrgMember(
    name: 'Emma Lefèvre',
    role: 'Monitrice E5',
    imagePath: 'assets/jpgs/macron.jpg',
    divesCount: 420,
  ),
  _OrgMember(
    name: 'Thomas Moreau',
    role: 'Moniteur E6',
    imagePath: 'assets/jpgs/macron.jpg',
    divesCount: 120,
  ),
  _OrgMember(
    name: 'Chloé Dubois',
    role: 'Monitrice E7',
    imagePath: 'assets/jpgs/macron.jpg',
    divesCount: 350,
  ),
  _OrgMember(
    name: 'Hugo Garnier',
    role: 'Moniteur E8',
    imagePath: 'assets/jpgs/macron.jpg',
    divesCount: 500,
  ),
  _OrgMember(
    name: 'Léa Richard',
    role: 'Monitrice E9',
    imagePath: 'assets/jpgs/macron.jpg',
    divesCount: 600,
  ),
];

/// ================= BADGES =================

class _FishBadge {
  final String label;
  final String imagePath;

  const _FishBadge(this.label, this.imagePath);

  static _FishBadge? fromDives(int? dives) {
    if (dives == null) return null;

    if (dives <= 20) {
      return const _FishBadge('Petit poisson', 'assets/pngs/clown.png');
    } else if (dives <= 50) {
      return const _FishBadge('Curieux', 'assets/pngs/ange.png');
    } else if (dives <= 100) {
      return const _FishBadge('À l’aise', 'assets/pngs/ballon.png');
    } else if (dives <= 200) {
      return const _FishBadge('Solide', 'assets/pngs/requin.png');
    } else if (dives <= 300) {
      return const _FishBadge('Très expérimenté', 'assets/pngs/orque.png');
    } else if (dives <= 400) {
      return const _FishBadge('Expert', 'assets/pngs/dauphin.png');
    } else {
      return const _FishBadge('Légende', 'assets/pngs/murene.png');
    }
  }
}

/// ================= UI =================

class _MemberTile extends StatelessWidget {
  final _OrgMember member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final badge = _FishBadge.fromDives(member.divesCount);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          /// 👤 AVATAR
          CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(member.imagePath),
          ),
          const SizedBox(width: 16),

          /// 👤 TEXTE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  member.role,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),

          /// 🐟 BADGE ANIMÉ
          if (badge != null)
            _AnimatedFishBadge(
              badge: badge,
              divesCount: member.divesCount!,
            ),
        ],
      ),
    );
  }
}


class _OrgButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OrgButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.9),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(label),
    );
  }
}

/// ================= GLASS =================

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassValue extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _GlassValue({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  text,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
class _AnimatedFishBadge extends StatelessWidget {
  final _FishBadge badge;
  final int divesCount;

  const _AnimatedFishBadge({
    required this.badge,
    required this.divesCount,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return AnimatedOpacity(
          opacity: scale < 0.9 ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Image.asset(
            badge.imagePath,
            height: 36,
            width: 36,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 4),
          Text(
            badge.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$divesCount plongées',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

