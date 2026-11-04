import 'package:flutter/material.dart';

class CarpoolCard extends StatelessWidget {
  final String creatorName;
  final bool booked, owned, request;
  final String departure;
  final int remainingSeats;
  final VoidCallback onReserve;

  const CarpoolCard({
    super.key,
    required this.creatorName,
    this.booked = false,
    this.request = false,
    this.owned = false,
    this.departure = '',
    required this.remainingSeats,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = remainingSeats <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFull
              ? Colors.grey
              : const Color(0xFFD4AF37).withOpacity(0.7),
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
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
                if (departure.isNotEmpty)
                  Text(departure, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  request
                      ? 'Recherche une place'
                      : isFull
                      ? 'Complet'
                      : '$remainingSeats place(s) restante(s)',
                  style: TextStyle(
                    color: isFull ? Colors.redAccent : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          /// ✅ ACTION
          ElevatedButton(
            onPressed: request || owned || (isFull && !booked)
                ? null
                : onReserve,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              request
                  ? 'Demande'
                  : owned
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
