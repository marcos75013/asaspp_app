import 'package:flutter/material.dart';
import '../../../core/widgets/member_avatar.dart';

class CarpoolCard extends StatelessWidget {
  final String creatorName;
  final int remainingSeats;
  final VoidCallback onReserve;
  final String? avatarUrl;
  final bool booked;
  final bool enabled;
  final VoidCallback? onShowPassengers;
  final bool owned;

  const CarpoolCard({
    super.key,
    required this.creatorName,
    required this.remainingSeats,
    required this.onReserve,
    this.avatarUrl,
    this.booked = false,
    this.enabled = true,
    this.onShowPassengers,
    this.owned = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isFull = remainingSeats <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant, width: 1.3),
      ),
      child: Row(
        children: [
          MemberAvatar(radius: 20, url: avatarUrl, name: creatorName),
          const SizedBox(width: 10),

          /// 👤 INFOS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creatorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isFull ? 'Complet' : '$remainingSeats place(s) restante(s)',
                  style: TextStyle(
                    color: isFull ? colors.error : colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onShowPassengers != null)
                  TextButton.icon(
                    onPressed: onShowPassengers,
                    icon: const Icon(Icons.people_outline, size: 18),
                    label: const Text('Voir les passagers'),
                  ),
              ],
            ),
          ),

          /// ✅ ACTION
          ElevatedButton(
            onPressed: (!enabled || (isFull && !booked)) ? null : onReserve,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              owned
                  ? 'Mon trajet'
                  : booked
                  ? 'Annuler'
                  : 'Réserver',
            ),
          ),
        ],
      ),
    );
  }
}
