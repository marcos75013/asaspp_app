import 'package:asaspp_app/features/home_page_admin/data/admin_api.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/pages/admin_text_resources_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAdminApi extends AdminApi {
  Map<String, dynamic>? saved;
  String? savedPath;
  @override
  Future<List<Map<String, dynamic>>> list(String path) async => [];
  @override
  Future<void> save(String path, Map<String, dynamic> body, {int? id}) async {
    savedPath = path;
    saved = body;
  }
}

void main() {
  testWidgets('enregistre un lien de paiement publié', (tester) async {
    final api = FakeAdminApi();
    await tester.pumpWidget(
      MaterialApp(home: AdminTextResourcesPage(payments: true, api: api)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Cotisation');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'https://example.org/payer',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(api.savedPath, '/api/payment-links');
    expect(api.saved, {
      'title': 'Cotisation',
      'url': 'https://example.org/payer',
      'published': true,
    });
  });
  testWidgets('refuse une URL invalide', (tester) async {
    final api = FakeAdminApi();
    await tester.pumpWidget(
      MaterialApp(home: AdminTextResourcesPage(payments: true, api: api)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Test');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'javascript:alert(1)',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(api.saved, isNull);
    expect(
      find.text('Saisissez un lien HTTP ou HTTPS valide.'),
      findsOneWidget,
    );
  });
  testWidgets('enregistre un message avec sa signature', (tester) async {
    final api = FakeAdminApi();
    await tester.pumpWidget(
      MaterialApp(home: AdminTextResourcesPage(payments: false, api: api)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Réunion');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Rendez-vous demain',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'Le bureau');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(api.savedPath, '/api/admin-association/messages');
    expect(api.saved, {
      'title': 'Réunion',
      'content': 'Rendez-vous demain',
      'signature': 'Le bureau',
      'published': true,
    });
  });
}
