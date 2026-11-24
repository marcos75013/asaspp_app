import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/auth_storage.dart';
import 'auth_session.dart';

class ApiClient {
  final AuthStorage _authStorage;
  final ApiConfig _apiConfig;

  ApiClient(this._authStorage, {ApiConfig apiConfig = const ApiConfig()})
    : _apiConfig = apiConfig;

  // Feature screens create separate clients but share the same saved session.
  static Future<String?>? _renewal;

  BaseOptions _options() => BaseOptions(
    baseUrl: _apiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  );

  late final Dio _sessionDio = Dio(_options())
    ..httpClientAdapter = dio.httpClientAdapter;

  late final Dio dio = Dio(_options())
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path.startsWith('/api/mobile/auth/')) {
            handler.next(options);
            return;
          }
          try {
            final token = await _accessToken();
            final associationId = await _authStorage.getActiveAssociationId();
            if (token != null)
              options.headers['Authorization'] = 'Bearer $token';

            final accountProfile =
                options.path == '/api/mobile/profile' ||
                options.path.startsWith('/api/mobile/profile/');
            if (associationId != null && !accountProfile) {
              options.headers['X-Association-Id'] = associationId.toString();
            }
            handler.next(options);
          } catch (error) {
            handler.reject(DioException(requestOptions: options, error: error));
          }
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.startsWith('/api/mobile/auth/')) {
            final session = await _authStorage.getSession();
            if (error.requestOptions.headers['Authorization'] ==
                (session.token == null ? null : 'Bearer ${session.token}')) {
              await _authStorage.clear();
              sessionExpired.value = true;
            }
          }
          handler.next(error);
        },
      ),
    );

  Future<String?> _accessToken() async {
    final session = await _authStorage.getSession();
    final refreshToken = session.refreshToken;
    if (refreshToken == null || !_nearExpiry(session.token)) {
      return session.token;
    }

    final pending = _renewal;
    if (pending != null) return pending;
    final renewal = _refresh(refreshToken);
    _renewal = renewal;
    try {
      return await renewal;
    } finally {
      _renewal = null;
    }
  }

  Future<String?> _refresh(String refreshToken) async {
    try {
      final response = await _sessionDio.post<Map<String, dynamic>>(
        '/api/mobile/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data!;
      final current = await _authStorage.getSession();
      if (current.refreshToken != refreshToken) return current.token;
      final token = data['token'] as String;
      await _authStorage.saveSession(token, data['refreshToken'] as String);
      return token;
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) rethrow;
      final current = await _authStorage.getSession();
      if (current.refreshToken != refreshToken) return current.token;
      await _authStorage.clear();
      sessionExpired.value = true;
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _renewal;
    } catch (_) {
      // Local sign-out still applies when renewal fails.
    }
    final session = await _authStorage.getSession();
    await _authStorage.clear();
    sessionExpired.value = true;
    if (session.refreshToken == null) return;
    try {
      await _sessionDio.post<void>(
        '/api/mobile/auth/logout',
        data: {'refreshToken': session.refreshToken},
      );
    } on DioException {
      // The locally removed token cannot be used by this client again.
    }
  }

  bool _nearExpiry(String? token) {
    try {
      final payload = token!.split('.')[1];
      final claims = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(payload))),
      );
      final expiration = (claims['exp'] as num) * 1000;
      return expiration <= DateTime.now().millisecondsSinceEpoch + 30000;
    } catch (_) {
      return true;
    }
  }
}
