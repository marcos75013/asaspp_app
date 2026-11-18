import '../../../../core/network/api_client.dart';
import '../models/photo_discussion.dart';

class PhotoInteractionsApiService {
  final ApiClient _client;
  const PhotoInteractionsApiService(this._client);

  String _path(String albumId, int photoId) =>
      '/api/gallery/$albumId/photos/$photoId';

  Future<PhotoDiscussion> load(String albumId, int photoId) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '${_path(albumId, photoId)}/interactions',
    );
    return PhotoDiscussion.fromJson(response.data ?? const {});
  }

  Future<PhotoDiscussion> setLiked(
    String albumId,
    int photoId,
    bool liked,
  ) async {
    final response = await _client.dio.put<Map<String, dynamic>>(
      '${_path(albumId, photoId)}/like',
      data: {'liked': liked},
    );
    return PhotoDiscussion.fromJson(response.data ?? const {});
  }

  Future<PhotoDiscussion> comment(
    String albumId,
    int photoId,
    String body,
  ) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '${_path(albumId, photoId)}/comments',
      data: {'body': body.trim()},
    );
    return PhotoDiscussion.fromJson(response.data ?? const {});
  }

  Future<PhotoDiscussion> removeComment(
    String albumId,
    int photoId,
    int commentId,
  ) async {
    final response = await _client.dio.delete<Map<String, dynamic>>(
      '${_path(albumId, photoId)}/comments/$commentId',
    );
    return PhotoDiscussion.fromJson(response.data ?? const {});
  }
}
