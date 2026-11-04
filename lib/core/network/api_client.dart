import 'package:dio/dio.dart';
import '../storage/auth_storage.dart';

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.36:8080',
  );
  final AuthStorage _authStorage;

  ApiClient(this._authStorage);

  late final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              if (options.path.startsWith('/api/mobile/auth/')) {
                handler.next(options);
                return;
              }
              final token = await _authStorage.getToken();
              final associationId = await _authStorage.getActiveAssociationId();

              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }

              if (associationId != null &&
                  !options.headers.containsKey('X-Association-Id')) {
                options.headers['X-Association-Id'] = associationId.toString();
              }

              handler.next(options);
            },
          ),
        );
}
