import 'package:asaspp_app/features/carpool/presentation/carpool_departure_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 24, 18);
  final eventStart = DateTime(2027, 2, 12, 15, 11);

  test('accepts a future departure before or at the event start', () {
    expect(
      validateCarpoolDeparture(
        departure: DateTime(2027, 2, 12, 13),
        eventStart: eventStart,
        now: now,
      ),
      isNull,
    );
    expect(
      validateCarpoolDeparture(
        departure: eventStart,
        eventStart: eventStart,
        now: now,
      ),
      isNull,
    );
  });

  test('rejects a departure after the event start', () {
    expect(
      validateCarpoolDeparture(
        departure: DateTime(2027, 2, 13, 17, 11),
        eventStart: eventStart,
        now: now,
      ),
      contains('avant le début'),
    );
  });

  test('rejects a missing or past departure', () {
    expect(
      validateCarpoolDeparture(
        departure: null,
        eventStart: eventStart,
        now: now,
      ),
      isNotNull,
    );
    expect(
      validateCarpoolDeparture(
        departure: now,
        eventStart: eventStart,
        now: now,
      ),
      contains('futur'),
    );
  });
}
