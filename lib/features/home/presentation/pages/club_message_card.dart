import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class ClubMessageCard extends StatelessWidget {
  const ClubMessageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // ⬅️ PLUS COMPACT
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ───────── HEADER COMPACT ─────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/jpgs/macron.jpg',
                    width: 40, // ⬅️ plus petit
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Message du président',
                    style: AppTextStyles.headline.copyWith(
                      fontSize: 15, // ⬅️ plus petit
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ───────── MESSAGE COMPACT ─────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Guillemet ouvrant (inline)
                  Text(
                    '“',
                    style: TextStyle(
                      fontSize: 28,
                      height: 1.2,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Texte
                  Expanded(
                    child: Text(
                      "Bande de plongeurs merguez, n'oubliez pas vos matos",
                      style: AppTextStyles.body.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Guillemet fermant (inline)
                  Text(
                    '”',
                    style: TextStyle(
                      fontSize: 28,
                      height: 1.2,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ───────── SIGNATURE COMPACTE ─────────
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— Yan Coomans',
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
