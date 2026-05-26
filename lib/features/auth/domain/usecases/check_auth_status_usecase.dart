import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  const CheckAuthStatusUseCase({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<bool> call() {
    return _authRepository.isAuthenticated();
  }
}