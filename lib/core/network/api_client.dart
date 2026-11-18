import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/auth_storage.dart';
import 'auth_session.dart';

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

              final accountProfile =
                  options.path == '/api/mobile/profile' ||
                  options.path.startsWith('/api/mobile/profile/');
              if (associationId != null && !accountProfile) {
                options.headers['X-Association-Id'] = associationId.toString();
              }

              handler.next(options);
            },
            onError: (error, handler) async {
              if (error.response?.statusCode == 401) {
                await _authStorage.clear();
                sessionExpired.value = true;
              }
              handler.next(error);
            },
          ),
        );
}
