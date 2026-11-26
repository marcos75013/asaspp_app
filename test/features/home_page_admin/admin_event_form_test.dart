import 'package:asaspp_app/features/home_page_admin/data/admin_api.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/pages/admin_event_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeEvents extends AdminApi {
  Map<String, dynamic>? body;
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
  testWidgets('envoie un entraînement à l’API avec son lieu', (tester) async {
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
    await tester.ensureVisible(find.text('Créer'));
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();
    expect(api.body?['eventKind'], 'TRAINING');
    expect(api.body?['title'], 'Piscine');
    expect(api.body?['location'], 'Paris');
    expect(api.body?['startDate'], isNotNull);
  });
}
