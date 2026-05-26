import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        super(const AuthState());

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  Future<void> checkAuthStatus() async {
    final isAuthenticated = await _checkAuthStatusUseCase();

    emit(
      state.copyWith(
        status: isAuthenticated
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        errorMessage: null,
      ),
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      await _loginUseCase(
        email: email,
        password: password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Email ou mot de passe incorrect',
        ),
      );
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();

    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      ),
    );
  }
}