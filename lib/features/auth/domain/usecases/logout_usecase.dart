import '../repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<void> call() {
    return _authRepository.logout();
  }
}