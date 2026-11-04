import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/association_repository.dart';
import '../../../connected/data/club_api.dart';
import '../../data/models/next_event_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AssociationRepository repository;
  int _request = 0;
  HomeCubit(this.repository) : super(const HomeState());
  Future<void> loadEvents() async {
    final request = ++_request;
    emit(const HomeState(loading: true));
    try {
      final api = await repository.api();
      final events = <int, NextEventModel>{};
      var page = 0;
      while (true) {
        final data = await api.events(page: page++);
        for (final item in records(data['content'])) {
          if (item['published'] == true) {
            final event = NextEventModel.fromJson(item);
            events[event.id] = event;
          }
        }
        if (data['last'] != false) break;
      }
      if (!isClosed && request == _request) emit(HomeState(nextEvents: events));
    } catch (error) {
      if (!isClosed && request == _request)
        emit(HomeState(error: readableError(error)));
    }
  }

  Future<void> setParticipation(int eventId, ParticipationStatus status) async {
    if (state.pending.contains(eventId)) return;
    final generation = _request;
    emit(state.copyWith(pending: {...state.pending, eventId}));
    try {
      final api = await repository.api();
      final data = await api.participate(eventId, switch (status) {
        ParticipationStatus.going => 'GOING',
        ParticipationStatus.maybe => 'MAYBE',
        _ => 'NOT_GOING',
      });
      if (!isClosed && generation == _request)
        emit(
          state.copyWith(
            nextEvents: {
              ...state.nextEvents,
              eventId: NextEventModel.fromJson(data),
            },
            pending: {...state.pending}..remove(eventId),
          ),
        );
    } catch (error) {
      if (!isClosed && generation == _request)
        emit(
          state.copyWith(
            error: readableError(error),
            pending: {...state.pending}..remove(eventId),
          ),
        );
    }
  }
}
