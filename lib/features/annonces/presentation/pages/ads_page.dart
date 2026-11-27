import '../../../../core/theme/pulse_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../data/services/ads_repository.dart';
import '../../data/services/mobile_ads_api_service.dart';
import '../cubit/ad_cubit.dart';
import '../cubit/ad_state.dart';
import '../data/models/ad_model.dart';
import '../widgets/ad_card.dart';
import 'create_ad_page.dart';

class AdsPage extends StatelessWidget {
  final AdsRepository? repository;

  const AdsPage({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    final theme = PulseTheme.build(Theme.of(context).brightness);
    final colors = theme.colorScheme;
    return Theme(
      data: theme,
      child: BlocProvider(
        create: (_) => AdsCubit(
          repository ?? MobileAdsApiService(ApiClient(AuthStorage())),
        )..loadAds(),
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Leboncourant",
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      /// ➕ PUBLISH BUTTON
                      Tooltip(
                        message: "Créer une annonce",
                        preferBelow: false,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () async {
                              final created = await Navigator.of(context)
                                  .push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => CreateAdPage(
                                        repository:
                                            repository ??
                                            MobileAdsApiService(
                                              ApiClient(AuthStorage()),
                                            ),
                                      ),
                                    ),
                                  );
                              if (created == true && context.mounted) {
                                await context.read<AdsCubit>().loadAds();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Publier",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                /// 🔎 SEARCH FIELD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BlocBuilder<AdsCubit, AdsState>(
                    builder: (context, state) {
                      return TextField(
                        style: TextStyle(color: colors.onSurface),
                        decoration: InputDecoration(
                          hintText: "Rechercher une annonce...",
                          hintStyle: TextStyle(color: colors.onSurfaceVariant),
                          prefixIcon: Icon(
                            Icons.search,
                            color: colors.onSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: colors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          context.read<AdsCubit>().search(value);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                /// FILTRES
                BlocBuilder<AdsCubit, AdsState>(
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FilterButton(
                          label: "Tous",
                          selected: state.selectedFilter == null,
                          onTap: () =>
                              context.read<AdsCubit>().filterByType(null),
                        ),
                        _FilterButton(
                          label: "Vente",
                          selected: state.selectedFilter == AdType.vente,
                          onTap: () => context.read<AdsCubit>().filterByType(
                            AdType.vente,
                          ),
                        ),
                        _FilterButton(
                          label: "Don",
                          selected: state.selectedFilter == AdType.don,
                          onTap: () =>
                              context.read<AdsCubit>().filterByType(AdType.don),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                /// LISTE
                Expanded(
                  child: BlocBuilder<AdsCubit, AdsState>(
                    builder: (context, state) {
                      if (state.isLoading && state.ads.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final filtered = context
                          .read<AdsCubit>()
                          .getFilteredAds();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            "Aucune annonce trouvée",
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: context.read<AdsCubit>().loadAds,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            140, // ⬅️ espace pour FAB + navbar
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: AdCard(ad: filtered[index]),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : colors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? colors.onPrimaryContainer
                : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
