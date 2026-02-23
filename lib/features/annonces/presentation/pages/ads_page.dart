import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ad_cubit.dart';
import '../cubit/ad_state.dart';
import '../data/models/ad_model.dart';
import '../widgets/ad_card.dart' hide AdsState;
import 'create_ad_page.dart';

class AdsPage extends StatelessWidget {
  const AdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return BlocProvider(
      create: (_) => AdsCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1E2D),

        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Leboncourant",
                      style: TextStyle(
                        color: Colors.white,
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
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreateAdPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B4D8),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
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
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Rechercher une annonce...",
                        hintStyle:
                        const TextStyle(color: Colors.white54),
                        prefixIcon:
                        const Icon(Icons.search, color: Colors.white54),
                        filled: true,
                        fillColor:
                        Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(30),
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
                    mainAxisAlignment:
                    MainAxisAlignment.center,
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

              /// LISTE
              Expanded(
                child: BlocBuilder<AdsCubit, AdsState>(
                  builder: (context, state) {
                    final filtered =
                    context.read<AdsCubit>().getFilteredAds();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          "Aucune annonce trouvée",
                          style:
                          TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        140, // ⬅️ espace pour FAB + navbar
                      ),
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
