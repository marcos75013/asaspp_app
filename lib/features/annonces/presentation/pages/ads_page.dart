import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/theme/pulse_theme.dart';
import '../../../../core/widgets/pulse_gradient_heading.dart';
import '../../../../core/widgets/pulse_page_header.dart';
import '../../../context/data/models/mobile_association_model.dart';
import '../../data/services/ads_repository.dart';
import '../../data/services/mobile_ads_api_service.dart';
import '../cubit/ad_cubit.dart';
import '../cubit/ad_state.dart';
import '../data/models/ad_model.dart';
import '../widgets/ad_card.dart';
import '../widgets/ad_image.dart';
import 'create_ad_page.dart';

class AdsPage extends StatelessWidget {
  const AdsPage({super.key, this.repository, this.association});

  final AdsRepository? repository;
  final MobileAssociationModel? association;

  @override
  Widget build(BuildContext context) {
    final adsRepository =
        repository ?? MobileAdsApiService(ApiClient(AuthStorage()));
    return Theme(
      data: PulseTheme.build(Theme.of(context).brightness),
      child: BlocProvider(
        create: (_) => AdsCubit(adsRepository)..loadAds(),
        child: BlocBuilder<AdsCubit, AdsState>(
          builder: (context, state) {
            final cubit = context.read<AdsCubit>();
            final theme = Theme.of(context);
            final colors = theme.colorScheme;
            final accent = marketplaceAccent(context);
            final typeFilterActive = !state.favoritesOnly && !state.mineOnly;
            final searchBorder = OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.outlineVariant),
            );
            final ads = cubit.getFilteredAds();

            return Scaffold(
              appBar: PulsePageHeader(
                title: 'Annonces',
                associationName: association?.associationName,
                logoUrl: association?.logoUrl,
                backLabel: 'Retour au club',
              ),
              body: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: cubit.loadAds,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: PulseTheme.pagePadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ENTRE MEMBRES',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: PulseTheme.headingGradient(
                                    theme.brightness,
                                  ).colors.last,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const PulseGradientHeading(
                                prefix: 'Lebon',
                                accent: 'courant',
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Vends, donne, partage. Les bonnes affaires du club.',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Rechercher une annonce…',
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: searchBorder,
                                  enabledBorder: searchBorder,
                                  focusedBorder: searchBorder.copyWith(
                                    borderSide: BorderSide(
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                                onChanged: cubit.search,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  for (final (label, selected, select) in [
                                    for (final (type, label) in [
                                      (null, 'Tous'),
                                      (AdType.vente, 'Vente'),
                                      (AdType.don, 'Don'),
                                    ])
                                      (
                                        label,
                                        typeFilterActive &&
                                            state.selectedFilter == type,
                                        () => cubit.filterByType(type),
                                      ),
                                    (
                                      'Favoris',
                                      state.favoritesOnly,
                                      cubit.filterFavorites,
                                    ),
                                    (
                                      'Mes annonces',
                                      state.mineOnly,
                                      cubit.filterMine,
                                    ),
                                  ])
                                    ChoiceChip(
                                      label: Text(label),
                                      selected: selected,
                                      onSelected: (_) => select(),
                                      showCheckmark: false,
                                      shape: const StadiumBorder(),
                                      side: BorderSide.none,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      backgroundColor: colors.surface,
                                      selectedColor: colors.primaryContainer,
                                      labelStyle: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: selected
                                                ? colors.onPrimaryContainer
                                                : colors.onSurfaceVariant,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Dernières annonces',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.errorMessage case final error?)
                        SliverToBoxAdapter(
                          child: ListTile(
                            title: Text(error),
                            trailing: TextButton(
                              onPressed: cubit.loadAds,
                              child: const Text('Actualiser'),
                            ),
                          ),
                        ),
                      if (state.isLoading && state.ads.isEmpty)
                        const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (ads.isEmpty && state.errorMessage == null)
                        const SliverToBoxAdapter(
                          child: Center(child: Text('Aucune annonce trouvée')),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          sliver: SliverGrid.builder(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 215,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  mainAxisExtent:
                                      210 +
                                      (MediaQuery.textScalerOf(
                                                    context,
                                                  ).scale(16) -
                                                  16)
                                              .clamp(0.0, double.infinity) *
                                          4,
                                ),
                            itemCount: ads.length,
                            itemBuilder: (_, index) => AdCard(
                              ad: ads[index],
                              repository: adsRepository,
                              association: association,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: theme.brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: () async {
                    final created = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => CreateAdPage(
                          repository: adsRepository,
                          association: association,
                        ),
                      ),
                    );
                    if (created == true && context.mounted) {
                      await cubit.loadAds();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Publier une annonce'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
