import '../../data/models/next_event_model.dart';

class HomeState {
  final Map<DiveType, NextEventModel> nextEvents;

  const HomeState({
    required this.nextEvents,
  });

  HomeState copyWith({
    Map<DiveType, NextEventModel>? nextEvents,
  }) {
    return HomeState(
      nextEvents: nextEvents ?? this.nextEvents,
    );
  }
}

