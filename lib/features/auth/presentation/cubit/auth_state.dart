
import '../../../context/data/models/mobile_context_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  selectAssociation,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final MobileContextModel? mobileContext;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.mobileContext,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    MobileContextModel? mobileContext,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      mobileContext: mobileContext ?? this.mobileContext,
    );
  }
}