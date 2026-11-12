import '../../presentation/data/models/ad_model.dart';

abstract interface class AdsRepository {
  Future<List<AdModel>> getAds();
  Future<AdModel> toggleFavorite(String id);
}
