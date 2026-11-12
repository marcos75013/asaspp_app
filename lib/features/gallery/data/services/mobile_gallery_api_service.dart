import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/gallery_model.dart';
import 'gallery_repository.dart';

class MobileGalleryApiService implements GalleryRepository {
  final ApiClient _apiClient;
  final ApiConfig _apiConfig;

  MobileGalleryApiService(
    this._apiClient, {
    ApiConfig apiConfig = const ApiConfig(),
  }) : _apiConfig = apiConfig;

  @override
  Future<List<GalleryModel>> getPublishedAlbums() async {
    final response = await _apiClient.dio.get<List<dynamic>>('/api/gallery');

    return (response.data ?? const [])
        .map(
          (album) => GalleryModel.fromJson(
            Map<String, dynamic>.from(album as Map),
            resolveUrl: _apiConfig.resolveUrl,
          ),
        )
        .toList();
  }
}
