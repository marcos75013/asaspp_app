import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/member_avatar.dart';
import '../../../context/data/models/mobile_association_model.dart';
import '../../data/services/ads_repository.dart';
import '../cubit/ad_cubit.dart';
import '../data/models/ad_model.dart';
import '../pages/ad_detail_page.dart';
import 'ad_image.dart';

class AdCard extends StatelessWidget {
  const AdCard({
    super.key,
    required this.ad,
    this.repository,
    this.association,
  });

  final AdModel ad;
  final AdsRepository? repository;
  final MobileAssociationModel? association;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    Future<void> open({bool manage = false}) async {
      final cubit = context.read<AdsCubit>();
      final deleted = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => AdDetailPage(
            ad: ad,
            repository: repository,
            initiallyManage: manage,
            association: association,
          ),
        ),
      );
      if (cubit.isClosed) return;
      if (deleted == true) {
        cubit.removeDeletedAd(ad.id);
      } else if (ad.isOwner) {
        await cubit.loadAds();
      }
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: open,
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
                  if (ad.isOwner)
                    Positioned(
                      top: 4,
                      left: 6,
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onPressed: () => open(manage: true),
                        child: const Text('Gérer'),
                      ),
                    ),
                  if (ad.isOwner &&
                      (!ad.isActive || ad.status != AdStatus.active))
                    Positioned(
                      left: 6,
                      bottom: 6,
                      right: 6,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              ad.visibilityLabel,
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ),
                      ),
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
