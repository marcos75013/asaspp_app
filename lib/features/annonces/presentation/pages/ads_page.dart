import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/theme/pulse_theme.dart';
import '../../data/services/ads_repository.dart';
import '../../data/services/mobile_ads_api_service.dart';
import '../cubit/ad_cubit.dart';
import '../cubit/ad_state.dart';
import '../data/models/ad_model.dart';
import '../widgets/ad_card.dart';
import '../widgets/ad_image.dart';
import 'create_ad_page.dart';

class AdsPage extends StatelessWidget {
  const AdsPage({super.key, this.repository});

  final AdsRepository? repository;

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
            final ads = cubit.getFilteredAds();

            return Scaffold(
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
                                'Leboncourant',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Vends, donne, partage.',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Rechercher une annonce…',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: colors.outlineVariant,
                                    ),
                                  ),
                                ),
                                onChanged: cubit.search,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  for (final (type, label) in [
                                    (null, 'Tous'),
                                    (AdType.vente, 'Vente'),
                                    (AdType.don, 'Don'),
                                  ])
                                    ChoiceChip(
                                      label: Text(label),
                                      selected:
                                          !state.favoritesOnly &&
                                          !state.mineOnly &&
                                          state.selectedFilter == type,
                                      onSelected: (_) =>
                                          cubit.filterByType(type),
                                    ),
                                  ChoiceChip(
                                    label: const Text('Favoris'),
                                    selected: state.favoritesOnly,
                                    onSelected: (_) => cubit.filterFavorites(),
                                  ),
                                  ChoiceChip(
                                    label: const Text('Mes annonces'),
                                    selected: state.mineOnly,
                                    onSelected: (_) => cubit.filterMine(),
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
                        builder: (_) => CreateAdPage(repository: adsRepository),
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
