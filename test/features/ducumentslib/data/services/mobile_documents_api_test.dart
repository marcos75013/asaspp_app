import 'dart:convert';
import 'dart:typed_data';
import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/features/ducumentslib/data/services/mobile_documents_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Adapter implements HttpClientAdapter {
  RequestOptions? request;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode([
        {
          'id': 4,
          'title': 'Fédération',
          'externalUrl': 'https://example.org',
          'contentType': 'text/uri-list',
        },
      ]),
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
  test('requests published links within the active association', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final storage = AuthStorage();
    await storage.saveActiveAssociationId(3);
    await storage.saveSession('token', null);
    final client = ApiClient(storage);
    final adapter = Adapter();
    client.dio.httpClientAdapter = adapter;
    final documents = await MobileDocumentsApiService(
      client,
    ).getPublishedDocuments();
    expect(adapter.request!.queryParameters['includeLinks'], true);
    expect(adapter.request!.headers['X-Association-Id'], '3');
    expect(documents.single.isLink, true);
    expect(documents.single.externalUrl, 'https://example.org');
  });
}
