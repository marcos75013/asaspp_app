import 'package:asaspp_app/features/home/data/models/next_event_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a published backend event', () {
    final event = NextEventModel.fromJson({
      'id': 12,
      'title': 'Entraînement fosse',
      'description': 'Travail technique',
      'location': 'Fosse de Villeneuve',
      'category': 'Fosse',
      'categoryImageUrl': '/event-categories/image.png',
      'startDate': '2026-11-14T08:30:00',
      'currentUserStatus': 'MAYBE',
    });

    expect(event.id, 12);
    expect(event.site, 'Fosse de Villeneuve');
    expect(event.date, 'Samedi 14 novembre');
    expect(event.time, '08h30');
    expect(event.diveType, DiveType.fosse);
    expect(event.category, 'Fosse');
    expect(event.categoryImageUrl, '/event-categories/image.png');
    expect(
      event.copyWith(participation: ParticipationStatus.going).categoryImageUrl,
      event.categoryImageUrl,
    );
    expect(event.participation, ParticipationStatus.maybe);
  });

  test('keeps waitlisted participation distinct from a confirmed place', () {
    final event = NextEventModel.fromJson({
      'id': 13,
      'title': 'Sortie mer',
      'startDate': '2026-11-15T09:00:00',
      'currentUserStatus': 'WAITLISTED',
    });

    expect(event.diveType, DiveType.autre);
    expect(event.participation, ParticipationStatus.waitlisted);
  });

  test('serializes participation statuses for the backend', () {
    expect(participationStatusToJson(ParticipationStatus.going), 'GOING');
    expect(participationStatusToJson(ParticipationStatus.maybe), 'MAYBE');
    expect(
      participationStatusToJson(ParticipationStatus.notGoing),
      'NOT_GOING',
    );
  });
}
