import 'package:dio/dio.dart';

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
  Future<AdModel> getAd(String id) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/marketplace/$id',
    );
    return AdModel.fromJson(
      response.data ?? const {},
      resolveUrl: _apiConfig.resolveUrl,
    );
  }

  @override
  Future<AdModel> setStatus(String id, AdStatus status) async {
    final response = await _apiClient.dio.patch<Map<String, dynamic>>(
      '/api/marketplace/$id/status',
      queryParameters: {'status': status.apiValue},
    );
    return AdModel.fromJson(
      response.data ?? const {},
      resolveUrl: _apiConfig.resolveUrl,
    );
  }

  @override
  Future<void> deleteAd(String id) async {
    await _apiClient.dio.delete<void>('/api/marketplace/$id');
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

  @override
  Future<AdModel> createAd(
    CreateAdInput input,
    List<AdImageUpload> images,
  ) async {
    final createResponse = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/marketplace',
      data: {
        'type': switch (input.type) {
          AdType.vente => 'SALE',
          AdType.recherche => 'WANTED',
          AdType.don => 'GIFT',
        },
        'title': input.title,
        'description': input.description,
        'price': input.type == AdType.don ? 0 : input.price,
        'contactPhone': input.contactPhone,
      },
    );
    var created = createResponse.data ?? const <String, dynamic>{};

    if (images.isNotEmpty) {
      try {
        final formData = FormData();
        for (final image in images) {
          formData.files.add(
            MapEntry(
              'files',
              MultipartFile.fromBytes(
                image.bytes,
                filename: image.filename,
                contentType: _imageContentType(image.filename),
              ),
            ),
          );
        }
        final uploadResponse = await _apiClient.dio.post<Map<String, dynamic>>(
          '/api/marketplace/${created['id']}/images',
          data: formData,
        );
        created = uploadResponse.data ?? created;
      } catch (_) {
        await deleteAd('${created['id']}');
        rethrow;
      }
    }

    return AdModel.fromJson(created, resolveUrl: _apiConfig.resolveUrl);
  }

  DioMediaType _imageContentType(String filename) {
    final extension = filename.toLowerCase().split('.').last;
    return switch (extension) {
      'png' => DioMediaType('image', 'png'),
      'webp' => DioMediaType('image', 'webp'),
      _ => DioMediaType('image', 'jpeg'),
    };
  }
}
