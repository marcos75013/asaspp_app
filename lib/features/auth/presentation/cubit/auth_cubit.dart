import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    await Future.delayed(const Duration(seconds: 1));

    // 🔥 LOGIN EN DUR (temporaire)
    if (email == "aaa" && password == "aaa") {
      emit(state.copyWith(status: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: "Email ou mot de passe incorrect",
      ));
    }
  }

  void logout() {
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }
}
