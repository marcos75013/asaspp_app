import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:typed_data';

import 'package:asaspp_app/core/config/api_config.dart';
import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/features/carpool/data/services/carpool_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CarpoolAdapter implements HttpClientAdapter {
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
    const post =
        '{"id":8,"eventId":4,"authorFirstName":"Alice",'
        '"authorLastName":"Martin","type":"OFFER","departureLocation":"Gare",'
        '"departureTime":"2026-12-01T08:00:00","seatCount":3,'
        '"availableSeatCount":2,"bookedByCurrentUser":false,'
        '"ownedByCurrentUser":false,"active":true}';
    return ResponseBody.fromString(
      options.path.endsWith('/passengers')
          ? '[{"userId":42,"firstName":"Alice","lastName":"Martin","avatarUrl":"/profile-images/abc"}]'
          : options.method == 'GET'
          ? '[$post]'
          : post,
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
  test('lists, creates, books and cancels for the current event', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final storage = AuthStorage();
    await storage.saveSession('token', null);
    await storage.saveActiveAssociationId(5);
    final adapter = _CarpoolAdapter();
    final client = ApiClient(
      storage,
      apiConfig: const ApiConfig(baseUrl: 'https://example.test'),
    );
    client.dio.httpClientAdapter = adapter;
    final api = CarpoolApiService(client);
    final posts = await api.list(4);
    expect(posts.single.remainingSeats, 2);
    await api.create(
      4,
      departureLocation: ' Gare ',
      departureTime: DateTime(2026, 12, 1, 8),
      seatCount: 3,
    );
    final passengers = await api.passengers(8);
    expect(passengers.single.name, 'Alice Martin');
    expect(passengers.single.avatarUrl, '/profile-images/abc');
    await api.book(8);
    await api.cancelBooking(8);
    expect(adapter.requests.map((r) => '${r.method} ${r.path}'), [
      'GET /api/events/4/carpools',
      'POST /api/events/4/carpools',
      'GET /api/carpools/8/passengers',
      'POST /api/carpools/8/bookings',
      'DELETE /api/carpools/8/bookings/mine',
    ]);
    expect(adapter.bodies[1], contains('"type":"OFFER"'));
    expect(adapter.bodies[1], contains('"departureLocation":"Gare"'));
    expect(
      adapter.requests.every((r) => r.headers['X-Association-Id'] == '5'),
      true,
    );
  });
}
