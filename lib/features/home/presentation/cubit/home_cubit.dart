import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/next_event_model.dart';
import '../../data/services/mobile_event_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final MobileEventRepository _eventRepository;

  HomeCubit({required MobileEventRepository eventRepository})
    : _eventRepository = eventRepository,
      super(const HomeState());

  Future<void> loadEvents() async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));

    try {
      final events = await _eventRepository.getFutureEvents();
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          nextEvents: events,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Impossible de récupérer les prochains événements',
        ),
      );
    }
  }

  Future<void> setParticipation(int eventId, ParticipationStatus status) async {
    final eventIndex = state.nextEvents.indexWhere(
      (event) => event.id == eventId,
    );
    if (eventIndex == -1 || status == ParticipationStatus.none) return;

    final previousEvent = state.nextEvents[eventIndex];
    final optimisticEvents = [...state.nextEvents];
    optimisticEvents[eventIndex] = previousEvent.copyWith(
      participation: status,
    );
    emit(state.copyWith(nextEvents: optimisticEvents));

    try {
      final updatedEvent = await _eventRepository.setParticipation(
        eventId,
        status,
      );
      final updatedEvents = [...state.nextEvents];
      final updatedIndex = updatedEvents.indexWhere(
        (event) => event.id == eventId,
      );
      if (updatedIndex != -1) updatedEvents[updatedIndex] = updatedEvent;
      emit(state.copyWith(nextEvents: updatedEvents, errorMessage: null));
    } catch (_) {
      final restoredEvents = [...state.nextEvents];
      final restoredIndex = restoredEvents.indexWhere(
        (event) => event.id == eventId,
      );
      if (restoredIndex != -1) restoredEvents[restoredIndex] = previousEvent;
      emit(
        state.copyWith(
          nextEvents: restoredEvents,
          errorMessage: 'Impossible d’enregistrer votre participation',
        ),
      );
    }
  }
}
