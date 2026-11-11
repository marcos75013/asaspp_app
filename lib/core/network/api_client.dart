import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/auth_storage.dart';

class ApiClient {
  final AuthStorage _authStorage;
  final ApiConfig _apiConfig;

  ApiClient(this._authStorage, {ApiConfig apiConfig = const ApiConfig()})
    : _apiConfig = apiConfig;

  late final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: _apiConfig.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await _authStorage.getToken();
              final associationId = await _authStorage.getActiveAssociationId();

              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }

              if (associationId != null) {
                options.headers['X-Association-Id'] = associationId.toString();
              }

              handler.next(options);
            },
          ),
        );
}
