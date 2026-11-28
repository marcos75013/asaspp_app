import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/member_avatar.dart';
import '../cubit/ad_cubit.dart';
import '../data/models/ad_model.dart';
import '../pages/ad_detail_page.dart';
import 'ad_image.dart';

class AdCard extends StatelessWidget {
  const AdCard({super.key, required this.ad});

  final AdModel ad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => AdDetailPage(ad: ad))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: ad.id,
                    child: AdImage(url: ad.image),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      tooltip: ad.isFavorite
                          ? 'Retirer des favoris'
                          : 'Ajouter aux favoris',
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surface,
                        foregroundColor: ad.isFavorite
                            ? colors.error
                            : colors.onSurface,
                      ),
                      onPressed: () =>
                          context.read<AdsCubit>().toggleFavorite(ad.id),
                      icon: Icon(
                        ad.isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.priceLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: marketplaceAccent(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ad.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      MemberAvatar(
                        radius: 9,
                        url: ad.sellerAvatar,
                        name: ad.sellerName,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          ad.sellerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
