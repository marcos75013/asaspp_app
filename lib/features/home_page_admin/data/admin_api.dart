import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';

class AdminApi {
  final ApiClient client;
  AdminApi({ApiClient? client}) : client = client ?? ApiClient(AuthStorage());
  Future<List<Map<String, dynamic>>> list(String path) async {
    final response = await client.dio.get<List<dynamic>>(
      path,
      queryParameters: path == '/api/payment-links'
          ? {'includeDrafts': true}
          : null,
    );
    return (response.data ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> save(String path, Map<String, dynamic> body, {int? id}) async {
    if (id == null) {
      await client.dio.post<dynamic>(path, data: body);
    } else {
      await client.dio.put<dynamic>('$path/$id', data: body);
    }
  }

  Future<void> delete(String path, int id) async {
    await client.dio.delete<void>('$path/$id');
  }

  Future<int> createAlbum(Map<String, dynamic> fields) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/api/gallery',
      queryParameters: fields,
    );
    return (response.data!['id'] as num).toInt();
  }

  Future<Map<String, dynamic>> createMember(Map<String, dynamic> fields) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/api/admin-association/members',
      data: fields,
    );
    return response.data ?? {};
  }

  Future<void> setMemberRole(int id, String role) async {
    await client.dio.put<dynamic>(
      '/api/admin-association/members/$id/role',
      data: {'role': role},
    );
  }

  Future<({List<Map<String, dynamic>> items, bool last})> eventPage({
    required bool training,
    required int page,
  }) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/api/events',
      queryParameters: {
        'eventKind': training ? 'TRAINING' : 'EVENT',
        'page': page,
        'size': 25,
        'sort': 'startDate,desc',
      },
    );
    final data = response.data!;
    return (
      items: (data['content'] as List).cast<Map<String, dynamic>>(),
      last: data['last'] == true,
    );
  }

  Future<void> updateEvent(
    int id,
    Map<String, dynamic> fields, {
    required bool following,
  }) async {
    await client.dio.patch<dynamic>(
      '/api/events/$id',
      data: fields,
      queryParameters: {'scope': following ? 'SERIES' : 'OCCURRENCE'},
    );
  }
}
