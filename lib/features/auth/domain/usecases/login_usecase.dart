import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<AuthSession> call({
    required String email,
    required String password,
  }) {
    return _authRepository.login(
      email: email,
      password: password,
    );
  }
}