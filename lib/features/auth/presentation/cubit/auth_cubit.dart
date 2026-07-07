import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/auth_storage.dart';
import '../../../context/data/services/mobile_context_api_service.dart';
import '../data/models/mobile_auth_api_service.dart';
import '../data/models/mobile_login_request.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final MobileAuthApiService _authApiService;
  final MobileContextApiService _contextApiService;
  final AuthStorage _authStorage;

  AuthCubit({
    required MobileAuthApiService authApiService,
    required MobileContextApiService contextApiService,
    required AuthStorage authStorage,
  })  : _authApiService = authApiService,
        _contextApiService = contextApiService,
        _authStorage = authStorage,
        super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      final loginResponse = await _authApiService.login(
        MobileLoginRequest(
          email: email,
          password: password,
        ),
      );

      await _authStorage.saveToken(loginResponse.token);

      final mobileContext = await _contextApiService.getContext();

      if (mobileContext.associations.isEmpty) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Aucune association associée à ce compte',
        ));
        return;
      }

      if (mobileContext.associations.length == 1) {
        await _authStorage.saveActiveAssociationId(
          mobileContext.associations.first.associationId,
        );

        emit(state.copyWith(
          status: AuthStatus.authenticated,
          mobileContext: mobileContext,
        ));
        return;
      }

      emit(state.copyWith(
        status: AuthStatus.selectAssociation,
        mobileContext: mobileContext,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Email ou mot de passe incorrect',
      ));
    }
  }

  Future<void> logout() async {
    await _authStorage.clear();
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }
}