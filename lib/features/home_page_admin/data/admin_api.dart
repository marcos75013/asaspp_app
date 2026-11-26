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
}
