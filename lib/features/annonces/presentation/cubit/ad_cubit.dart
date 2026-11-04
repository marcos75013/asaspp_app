import '../../../connected/data/club_api.dart';
import '../../../../core/data/association_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/ad_model.dart';
import 'ad_state.dart';

class AdsCubit extends Cubit<AdsState> {
  final AssociationRepository repository;
  AdsCubit(this.repository) : super(AdsState.initial()) {
    loadAds();
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

  AdModel _model(Json row, ClubApi api) {
    final images = records(row['images'] ?? []);
    return AdModel(
      id: '${row['id']}',
      title: label(row, 'title'),
      description: label(row, 'description'),
      image: images.isEmpty ? '' : api.imageUrl(label(images.first, 'url')),
      price: (row['price'] as num? ?? 0).toDouble(),
      sellerName:
          '${label(row, 'authorFirstName')} ${label(row, 'authorLastName')}',
      sellerAvatar: '',
      contactEmail: label(row, 'authorEmail'),
      contactPhone: label(row, 'contactPhone'),
      createdAt: DateTime.tryParse(label(row, 'createdAt')) ?? DateTime.now(),
      type: switch (row['type']) {
        'GIFT' => AdType.don,
        'WANTED' => AdType.recherche,
        _ => AdType.vente,
      },
      isFavorite: row['favorite'] == true,
    );
  }

  Future<void> loadAds() async {
    emit(state.copyWith(isLoading: true));
    try {
      final api = await repository.api();
      final data = await api.list('/api/marketplace');
      if (!isClosed)
        emit(
          state.copyWith(
            ads: data.map((row) => _model(row, api)).toList(),
            isLoading: false,
          ),
        );
    } catch (error) {
      if (!isClosed)
        emit(state.copyWith(isLoading: false, error: readableError(error)));
    }
  }

  final Set<String> _pending = {};
  Future<void> toggleFavorite(String id) async {
    if (!_pending.add(id)) return;
    try {
      final api = await repository.api();
      final result = await api.request(
        '/api/marketplace/$id/favorite',
        method: 'POST',
      );
      if (!isClosed)
        emit(
          state.copyWith(
            ads: state.ads
                .map(
                  (a) => a.id == id
                      ? _model(Map<String, dynamic>.from(result), api)
                      : a,
                )
                .toList(),
          ),
        );
    } catch (error) {
      if (!isClosed) emit(state.copyWith(error: readableError(error)));
    } finally {
      _pending.remove(id);
    }
  }

  void filterByType(AdType? type) {
    emit(state.copyWith(selectedFilter: type, clearFilter: type == null));
  }
}
