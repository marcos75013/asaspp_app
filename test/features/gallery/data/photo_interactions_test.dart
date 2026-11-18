import 'dart:typed_data';

import 'package:asaspp_app/core/config/api_config.dart';
import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/features/gallery/data/services/photo_interactions_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  final bodies = <String>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    bodies.add(
      requestStream == null
          ? ''
          : String.fromCharCodes(
              await requestStream.expand((chunk) => chunk).toList(),
            ),
    );
    return ResponseBody.fromString(
      '{"likes":2,"liked":true,"comments":[{"id":9,"author":"Aline","body":"Super photo","authorAvatarUrl":"/profile-images/abc"}]}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('loads, likes and comments on the selected association photo', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = AuthStorage();
    await storage.saveToken('token');
    await storage.saveActiveAssociationId(12);
    final adapter = _Adapter();
    final client = ApiClient(
      storage,
      apiConfig: const ApiConfig(baseUrl: 'https://example.test'),
    );
    client.dio.httpClientAdapter = adapter;
    final api = PhotoInteractionsApiService(client);

    final discussion = await api.load('7', 3);
    expect(discussion.likes, 2);
    expect(discussion.comments.single.authorAvatarUrl, '/profile-images/abc');
    await api.setLiked('7', 3, false);
    await api.comment('7', 3, ' Bravo ');
    expect(adapter.requests.map((r) => r.method), ['GET', 'PUT', 'POST']);
    expect(
      adapter.requests.every((r) => r.headers['X-Association-Id'] == '12'),
      true,
    );
    expect(
      adapter.requests.every(
        (r) => r.headers['Authorization'] == 'Bearer token',
      ),
      true,
    );
    expect(adapter.bodies[1], contains('"liked":false'));
    expect(adapter.bodies[2], contains('"body":"Bravo"'));
  });
}
