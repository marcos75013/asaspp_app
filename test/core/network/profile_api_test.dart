import 'dart:typed_data';

import 'package:asaspp_app/core/config/api_config.dart';
import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/network/auth_session.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/features/user/data/services/mobile_profile_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  final bodies = <String>[];
  int statusCode = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final bytes = requestStream == null
        ? <int>[]
        : await requestStream.expand((chunk) => chunk).toList();
    bodies.add(String.fromCharCodes(bytes));
    return ResponseBody.fromString(
      '{"id":7,"email":"a@b.test","firstName":"A","lastName":"B","avatarUrl":"/profile-images/new"}',
      statusCode,
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    sessionExpired.value = false;
  });

  test(
    'profile requests omit association and upload has multipart boundary',
    () async {
      final adapter = RecordingAdapter();
      final storage = AuthStorage();
      await storage.saveToken('test-token');
      await storage.saveActiveAssociationId(42);
      final client = ApiClient(
        storage,
        apiConfig: const ApiConfig(baseUrl: 'https://example.test'),
      );
      client.dio.httpClientAdapter = adapter;
      final profile = MobileProfileApiService(client);

      final user = await profile.getProfile();
      expect(user.avatarUrl, '/profile-images/new');
      await profile.uploadAvatar(
        PreparedAvatar(Uint8List.fromList([1, 2, 3]), 'avatar.jpg'),
      );
      await profile.deleteAvatar();
      expect(adapter.requests.map((r) => r.method), ['GET', 'PUT', 'DELETE']);
      for (final request in adapter.requests) {
        expect(request.headers['Authorization'], 'Bearer test-token');
        expect(request.headers['X-Association-Id'], isNull);
      }
      final type =
          adapter.requests[1].headers[Headers.contentTypeHeader] as String;
      expect(type, startsWith('multipart/form-data; boundary='));
      expect(adapter.bodies[1], contains('name="file"'));
    },
  );

  test('401 expires session while 403 preserves it', () async {
    final adapter = RecordingAdapter()..statusCode = 403;
    final storage = AuthStorage();
    await storage.saveToken('test-token');
    final client = ApiClient(
      storage,
      apiConfig: const ApiConfig(baseUrl: 'https://example.test'),
    );
    client.dio.httpClientAdapter = adapter;
    await expectLater(
      client.dio.get('/restricted'),
      throwsA(isA<DioException>()),
    );
    expect(await storage.getToken(), 'test-token');
    expect(sessionExpired.value, false);
    adapter.statusCode = 401;
    await expectLater(client.dio.get('/expired'), throwsA(isA<DioException>()));
    expect(await storage.getToken(), isNull);
    expect(sessionExpired.value, true);
  });
}
