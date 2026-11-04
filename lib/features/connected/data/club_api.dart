import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';

typedef Json = Map<String, dynamic>;

List<Json> records(dynamic data) => (data as List)
    .map((value) => Map<String, dynamic>.from(value as Map))
    .toList();
String label(Json item, String key, [String fallback = '']) =>
    item[key]?.toString() ?? fallback;

/// A session is bound to one association. In-flight requests cannot silently
/// switch tenants when the selection saved in preferences changes.
class ClubApi {
  final Dio dio;
  final int associationId;
  ClubApi(this.associationId, {Dio? client})
    : dio = client ?? ApiClient(AuthStorage()).dio;

  Future<dynamic> request(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? query,
    ResponseType? responseType,
  }) async {
    final response = await dio.request<dynamic>(
      path,
      data: data,
      queryParameters: query,
      options: Options(
        method: method,
        responseType: responseType,
        headers: {'X-Association-Id': '$associationId'},
      ),
    );
    return response.data;
  }

  Future<List<Json>> list(String path, {Map<String, dynamic>? query}) async =>
      records(await request(path, query: query));

  Future<Json> events({int page = 0, String query = ''}) async =>
      Map<String, dynamic>.from(
        await request(
              '/api/events',
              query: {
                'future': true,
                'page': page,
                'size': 20,
                if (query.isNotEmpty) 'title': query,
              },
            )
            as Map,
      );

  Future<Json> participate(int id, String status) async =>
      Map<String, dynamic>.from(
        await request(
              '/api/events/$id/participation',
              method: 'PUT',
              data: {'status': status},
            )
            as Map,
      );

  String imageUrl(String path) {
    final uri = Uri.parse(ApiClient.baseUrl).resolve(path);
    return uri.scheme == 'https' || uri.scheme == 'http' ? uri.toString() : '';
  }
}

String readableError(Object error) {
  if (error is StateError) return error.message;
  if (error is DioException) {
    switch (error.response?.statusCode) {
      case 401:
        return 'Votre session a expiré. Reconnectez-vous depuis votre profil.';
      case 403:
        return 'Ce module ou cette action n’est plus accessible pour votre compte.';
      case 404:
        return 'Ce contenu n’est plus disponible.';
      case 409:
        return 'La situation a changé. Actualisez la page avant de réessayer.';
    }
    final data = error.response?.data;
    if (data is Map &&
        data['message'] is String &&
        (error.response?.statusCode ?? 500) < 500) {
      return data['message'] as String;
    }
  }
  return 'Impossible de joindre l’association. Vérifiez votre connexion et réessayez.';
}
