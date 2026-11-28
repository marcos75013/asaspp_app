import '../../presentation/data/models/ad_model.dart';

abstract interface class AdsRepository {
  Future<List<AdModel>> getAds();
  Future<AdModel> getAd(String id);
  Future<AdModel> setStatus(String id, AdStatus status);
  Future<AdModel> toggleFavorite(String id);
  Future<AdModel> createAd(CreateAdInput input, List<AdImageUpload> images);
}

class CreateAdInput {
  final AdType type;
  final String title;
  final String description;
  final double? price;
  final String? contactPhone;

  const CreateAdInput({
    required this.type,
    required this.title,
    required this.description,
    required this.price,
    required this.contactPhone,
  });
}

class AdImageUpload {
  final List<int> bytes;
  final String filename;

  const AdImageUpload({required this.bytes, required this.filename});
}
