import '../../data/models/next_event_model.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final HomeStatus status;
  final List<NextEventModel> nextEvents;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.nextEvents = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<NextEventModel>? nextEvents,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      nextEvents: nextEvents ?? this.nextEvents,
      errorMessage: errorMessage,
    );
  }
}
