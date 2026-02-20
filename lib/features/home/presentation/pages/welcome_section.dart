import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenue 🤿',
          style: AppTextStyles.headline,
        ),
        const SizedBox(height: 8),
        Text(
          'Retrouve ici les infos du club, les sorties à venir et les annonces importantes.',
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}
