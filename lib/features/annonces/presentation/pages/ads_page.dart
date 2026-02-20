import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ad_cubit.dart';
import '../cubit/ad_state.dart';
import '../data/models/ad_model.dart';
import '../widgets/ad_card.dart' hide AdsState;

class AdsPage extends StatelessWidget {
  const AdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdsCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1E2D),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Leboncourant",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
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
                        selected:
                        state.selectedFilter == AdType.vente,
                        onTap: () => context
                            .read<AdsCubit>()
                            .filterByType(AdType.vente),
                      ),
                      _FilterButton(
                        label: "Recherche",
                        selected:
                        state.selectedFilter == AdType.recherche,
                        onTap: () => context
                            .read<AdsCubit>()
                            .filterByType(AdType.recherche),
                      ),
                      _FilterButton(
                        label: "Don",
                        selected:
                        state.selectedFilter == AdType.don,
                        onTap: () => context
                            .read<AdsCubit>()
                            .filterByType(AdType.don),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              Expanded(
                child: BlocBuilder<AdsCubit, AdsState>(
                  builder: (context, state) {
                    final filtered = state.selectedFilter == null
                        ? state.ads
                        : state.ads
                        .where((ad) =>
                    ad.type == state.selectedFilter)
                        .toList();

                    return ListView.builder(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding:
                          const EdgeInsets.only(bottom: 20),
                          child: AdCard(ad: filtered[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF00B4D8)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
