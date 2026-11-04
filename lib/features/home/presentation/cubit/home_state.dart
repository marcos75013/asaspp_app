import '../../data/models/next_event_model.dart';

class HomeState {
  final Map<int, NextEventModel> nextEvents;
  final bool loading;
  final String? error;
  final Set<int> pending;
  const HomeState({
    this.nextEvents = const {},
    this.loading = false,
    this.error,
    this.pending = const {},
  });
  HomeState copyWith({
    Map<int, NextEventModel>? nextEvents,
    bool? loading,
    String? error,
    Set<int>? pending,
  }) => HomeState(
    nextEvents: nextEvents ?? this.nextEvents,
    loading: loading ?? this.loading,
    error: error,
    pending: pending ?? this.pending,
  );
}
