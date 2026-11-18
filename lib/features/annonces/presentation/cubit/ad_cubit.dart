import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/ads_repository.dart';
import '../data/models/ad_model.dart';
import 'ad_state.dart';
import '../../../user/data/profile_updates.dart';

class AdsCubit extends Cubit<AdsState> {
  final AdsRepository _repository;

  AdsCubit(this._repository) : super(AdsState.initial()) {
    profileUpdates.addListener(loadAds);
  }

  @override
  Future<void> close() {
    profileUpdates.removeListener(loadAds);
    return super.close();
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  List<AdModel> getFilteredAds() {
    List<AdModel> filtered = state.ads;

    /// 🔹 Filtre type
    if (state.selectedFilter != null) {
      filtered = filtered
          .where((ad) => ad.type == state.selectedFilter)
          .toList();
    }

    /// 🔹 Filtre recherche (dès 3 lettres)
    if (state.searchQuery.length >= 3) {
      final q = state.searchQuery.toLowerCase();

      filtered = filtered.where((ad) {
        return ad.title.toLowerCase().contains(q) ||
            ad.description.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
  }

  Future<void> loadAds() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final ads = await _repository.getAds();
      ads.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(state.copyWith(ads: ads, isLoading: false, clearError: true));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Impossible de charger les annonces.',
        ),
      );
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final updatedAd = await _repository.toggleFavorite(id);
      final updated = state.ads
          .map((ad) => ad.id == id ? updatedAd : ad)
          .toList();
      emit(state.copyWith(ads: updated, clearError: true));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Impossible de modifier ce favori.'));
    }
  }

  void filterByType(AdType? type) {
    emit(
      state.copyWith(selectedFilter: type, clearSelectedFilter: type == null),
    );
  }
}
