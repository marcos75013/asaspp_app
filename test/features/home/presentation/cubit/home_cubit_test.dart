import 'package:asaspp_app/features/home/data/models/next_event_model.dart';
import 'package:asaspp_app/features/home/data/services/mobile_event_repository.dart';
import 'package:asaspp_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asaspp_app/features/home/presentation/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEventRepository implements MobileEventRepository {
  final List<NextEventModel> events;
  final bool failParticipation;

  const _FakeEventRepository({
    required this.events,
    this.failParticipation = false,
  });

  @override
  Future<List<NextEventModel>> getFutureEvents() async => events;

  @override
  Future<NextEventModel> setParticipation(
    int eventId,
    ParticipationStatus status,
  ) async {
    if (failParticipation) throw Exception('network error');

    return events
        .firstWhere((event) => event.id == eventId)
        .copyWith(participation: status);
  }
}

void main() {
  final event = NextEventModel(
    id: 12,
    title: 'Entraînement fosse',
    site: 'Fosse de Villeneuve',
    startDate: DateTime(2026, 11, 14, 8, 30),
    diveType: DiveType.fosse,
    message: 'Travail technique',
  );

  test('loads future events', () async {
    final cubit = HomeCubit(
      eventRepository: _FakeEventRepository(events: [event]),
    );

    await cubit.loadEvents();

    expect(cubit.state.status, HomeStatus.loaded);
    expect(cubit.state.nextEvents, [event]);
    await cubit.close();
  });

  test('persists participation', () async {
    final cubit = HomeCubit(
      eventRepository: _FakeEventRepository(events: [event]),
    );
    await cubit.loadEvents();

    await cubit.setParticipation(event.id, ParticipationStatus.going);

    expect(
      cubit.state.nextEvents.single.participation,
      ParticipationStatus.going,
    );
    expect(cubit.state.errorMessage, isNull);
    await cubit.close();
  });

  test('restores participation when persistence fails', () async {
    final cubit = HomeCubit(
      eventRepository: _FakeEventRepository(
        events: [event],
        failParticipation: true,
      ),
    );
    await cubit.loadEvents();

    await cubit.setParticipation(event.id, ParticipationStatus.maybe);

    expect(
      cubit.state.nextEvents.single.participation,
      ParticipationStatus.none,
    );
    expect(cubit.state.errorMessage, isNotEmpty);
    await cubit.close();
  });
}
