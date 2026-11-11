import '../models/next_event_model.dart';

abstract interface class MobileEventRepository {
  Future<List<NextEventModel>> getFutureEvents();

  Future<NextEventModel> setParticipation(
    int eventId,
    ParticipationStatus status,
  );
}
