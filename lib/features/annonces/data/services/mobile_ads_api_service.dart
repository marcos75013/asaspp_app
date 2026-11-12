import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../presentation/data/models/ad_model.dart';
import 'ads_repository.dart';

class MobileAdsApiService implements AdsRepository {
  final ApiClient _apiClient;
  final ApiConfig _apiConfig;

  MobileAdsApiService(
    this._apiClient, {
    ApiConfig apiConfig = const ApiConfig(),
  }) : _apiConfig = apiConfig;

  @override
  Future<List<AdModel>> getAds() async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/marketplace',
    );
    return (response.data ?? const [])
        .map(
          (item) => AdModel.fromJson(
            Map<String, dynamic>.from(item as Map),
            resolveUrl: _apiConfig.resolveUrl,
          ),
        )
        .toList();
  }

  @override
  Future<AdModel> toggleFavorite(String id) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/marketplace/$id/favorite',
    );
    return AdModel.fromJson(
      response.data ?? const {},
      resolveUrl: _apiConfig.resolveUrl,
    );
  }
}
