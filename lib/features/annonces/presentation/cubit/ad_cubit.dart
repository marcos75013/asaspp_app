import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/ad_model.dart';
import 'ad_state.dart';

class AdsCubit extends Cubit<AdsState> {
  AdsCubit() : super(AdsState.initial()) {
    loadAds();
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  List<AdModel> getFilteredAds() {
    List<AdModel> filtered = state.ads;

    /// 🔹 Filtre type
    if (state.selectedFilter != null) {
      filtered =
          filtered.where((ad) => ad.type == state.selectedFilter).toList();
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

  void loadAds() {
    final mockAds = [
      AdModel(
        id: "1",
        title: "Combinaison 5mm Homme",
        description:
        "Très bon état, utilisée 3 fois. Taille L.",
        image: "assets/annonces/annonce1.jpg",
        price: 120,
        sellerName: "Marcos",
        sellerAvatar: "assets/jpgs/macron.jpg",
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        type: AdType.vente,
      ),
      AdModel(
        id: "2",
        title: "Détendeur Scubapro MK25",
        description: "Révisé cette année, tres bonne qualité lorem ipsum, lorem ipsum, lorem ipsum, lorem ipsum, lorem ipsum, lorem ipsum.",
        image: "assets/annonces/annonce2.jpg",
        price: 250,
        sellerName: "Thomas",
        sellerAvatar: "assets/jpgs/macron.jpg",
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        type: AdType.vente,
      ),
      AdModel(
        id: "3",
        title: "Gilet stabilisateur Mares",
        description: "Taille M, très confortable.",
        image: "assets/annonces/annonce3.jpg",
        price: 180,
        sellerName: "Claire",
        sellerAvatar: "assets/jpgs/macron.jpg",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        type: AdType.vente,
      ),
      AdModel(
        id: "4",
        title: "Recherche lampe vidéo",
        description: "Je cherche 4000+ lumens.",
        image: "assets/annonces/annonce4.jpg",
        price: 0,
        sellerName: "Julien",
        sellerAvatar: "assets/jpgs/macron.jpg",
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        type: AdType.recherche,
      ),
      AdModel(
        id: "5",
        title: "Don masque junior",
        description: "Masque enfant en bon état.",
        image: "assets/annonces/annonce5.jpg",
        price: 0,
        sellerName: "Sophie",
        sellerAvatar: "assets/jpgs/macron.jpg",
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        type: AdType.don,
      ),
      AdModel(
        id: "6",
        title: "Ordinateur Cressi Leonardo",
        description: "Batterie neuve.",
        image: "assets/annonces/annonce6.jpg",
        price: 140,
        sellerName: "Antoine",
        sellerAvatar: "assets/jpgs/macron.jpg",
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        type: AdType.vente,
      ),
    ];

    // 💎 TRI automatique
    mockAds.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    emit(state.copyWith(ads: mockAds));
  }

  void toggleFavorite(String id) {
    final updated = state.ads.map((ad) {
      if (ad.id == id) {
        return ad.copyWith(isFavorite: !ad.isFavorite);
      }
      return ad;
    }).toList();

    emit(state.copyWith(ads: updated));
  }

  void filterByType(AdType? type) {
    emit(state.copyWith(selectedFilter: type));
  }
}
