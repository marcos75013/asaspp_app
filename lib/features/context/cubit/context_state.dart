import '../data/models/mobile_context_model.dart';

enum ContextStatus {
  initial,
  loading,
  loaded,
  error,
}

class ContextState {
  final ContextStatus status;
  final MobileContextModel? context;
  final String? errorMessage;

  const ContextState({
    this.status = ContextStatus.initial,
    this.context,
    this.errorMessage,
  });

  ContextState copyWith({
    ContextStatus? status,
    MobileContextModel? context,
    String? errorMessage,
  }) {
    return ContextState(
      status: status ?? this.status,
      context: context ?? this.context,
      errorMessage: errorMessage,
    );
  }
}