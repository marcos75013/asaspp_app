import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorageService,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorageService = secureStorageService;

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorageService;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final authSession = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    if (authSession.accessToken.isEmpty) {
      throw Exception('Access token vide');
    }

    await _secureStorageService.saveAccessToken(
      authSession.accessToken,
    );

    return authSession;
  }

  @override
  Future<void> logout() async {
    await _secureStorageService.deleteAccessToken();
  }

  @override
  Future<bool> isAuthenticated() async {
    final accessToken = await _secureStorageService.getAccessToken();

    return accessToken != null && accessToken.isNotEmpty;
  }
}