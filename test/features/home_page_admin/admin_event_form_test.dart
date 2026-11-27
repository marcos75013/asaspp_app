import 'package:asaspp_app/features/home_page_admin/data/admin_api.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/pages/admin_event_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeEvents extends AdminApi {
  Map<String, dynamic>? body;
  ({int id, bool following})? update;
  @override
  Future<void> updateEvent(
    int id,
    Map<String, dynamic> fields, {
    required bool following,
  }) async {
    update = (id: id, following: following);
    body = fields;
  }

  @override
  Future<List<Map<String, dynamic>>> list(String path) async => [
    {'id': 3, 'name': 'Sortie'},
  ];
  @override
  Future<void> save(String path, Map<String, dynamic> value, {int? id}) async {
    body = value;
  }
}

void main() {
  testWidgets('refuse la création sans titre ni date', (tester) async {
    final api = FakeEvents();
    await tester.pumpWidget(
      MaterialApp(home: AdminEventForm(training: true, api: api)),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Créer'));
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();
    expect(find.text('Le titre est obligatoire.'), findsOneWidget);
    expect(api.body, isNull);
  });
  testWidgets('charge les types réels pour un événement', (tester) async {
    final api = FakeEvents();
    await tester.pumpWidget(
      MaterialApp(home: AdminEventForm(training: false, api: api)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    expect(find.text('Sortie'), findsOneWidget);
  });
  testWidgets('envoie le lieu et la règle de récurrence de l’entraînement', (
    tester,
  ) async {
    final api = FakeEvents();
    await tester.pumpWidget(
      MaterialApp(home: AdminEventForm(training: true, api: api)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Piscine');
    await tester.enterText(find.byType(TextFormField).at(1), 'Paris');
    await tester.tap(find.text('Début'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Entraînement récurrent'));
    await tester.tap(find.text('Entraînement récurrent'));
    await tester.pumpAndSettle();
    final interval = find.byType(DropdownButtonFormField<int>);
    await tester.ensureVisible(interval);
    await tester.tap(interval);
    await tester.pumpAndSettle();
    await tester.tap(find.text('2').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Lun.'));
    await tester.tap(find.text('Lun.'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Répéter jusqu’au'));
    await tester.tap(find.text('Répéter jusqu’au'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Créer'));
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();
    expect(api.body?['eventKind'], 'TRAINING');
    expect(api.body?['title'], 'Piscine');
    expect(api.body?['location'], 'Paris');
    expect(api.body?['startDate'], isNotNull);
    expect(api.body?['recurrenceFrequency'], 'WEEKLY');
    expect(api.body?['recurrenceInterval'], 2);
    expect(api.body?['recurrenceDays'], ['MONDAY']);
    expect(api.body?['recurrenceUntil'], isNotNull);
  });
  for (final following in [false, true]) {
    testWidgets(
      'modifie seulement les champs saisis, scope suivant=$following',
      (tester) async {
        final api = FakeEvents();
        await tester.pumpWidget(
          MaterialApp(
            home: AdminEventForm(
              training: true,
              api: api,
              occurrence: {
                'id': 42,
                'title': 'Piscine',
                'location': 'Paris',
                'startDate': '2026-12-10T18:00:00',
                'published': true,
                'recurrenceSeriesId': 'series-test',
              },
            ),
          ),
        );
        await tester.enterText(find.byType(TextFormField).at(1), 'Lyon');
        if (following) {
          final scope = find.byType(DropdownButtonFormField<bool>);
          await tester.ensureVisible(scope);
          await tester.tap(scope);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Cette date et les suivantes').last);
          await tester.pumpAndSettle();
        }
        await tester.ensureVisible(find.text('Enregistrer'));
        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();
        expect(api.update, (id: 42, following: following));
        expect(api.body, {'location': 'Lyon'});
      },
    );
  }
}
