import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/auth_storage.dart';
import '../data/models/mobile_association_model.dart';
import '../data/services/mobile_context_api_service.dart';
import 'context_state.dart';

class ContextCubit extends Cubit<ContextState> {
  final MobileContextApiService _contextApiService;
  final AuthStorage _authStorage;

  ContextCubit({
    required MobileContextApiService contextApiService,
    required AuthStorage authStorage,
  })  : _contextApiService = contextApiService,
        _authStorage = authStorage,
        super(const ContextState());

  Future<void> loadContext() async {
    emit(state.copyWith(
      status: ContextStatus.loading,
      errorMessage: null,
    ));

    try {
      final mobileContext = await _contextApiService.getContext();
      final activeAssociationId = await _authStorage.getActiveAssociationId();

      MobileAssociationModel? selectedAssociation;

      if (activeAssociationId != null) {
        for (final association in mobileContext.associations) {
          if (association.associationId == activeAssociationId) {
            selectedAssociation = association;
            break;
          }
        }
      }

      selectedAssociation ??= mobileContext.currentAssociation;

      emit(state.copyWith(
        status: ContextStatus.loaded,
        context: mobileContext.copyWith(
          activeAssociation: selectedAssociation,
        ),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ContextStatus.error,
        errorMessage: 'Impossible de récupérer le contexte utilisateur',
      ));
    }
  }

  void clear() {
    emit(const ContextState());
  }
}