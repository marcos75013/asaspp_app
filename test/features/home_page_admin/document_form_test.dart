import 'package:asaspp_app/features/home_page_admin/data/admin_api.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/pages/document_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDocs extends AdminApi {
  Map<String, dynamic>? body;
  String? path;
  @override
  Future<List<Map<String, dynamic>>> list(String path) async => [];
  @override
  Future<void> save(String p, Map<String, dynamic> b, {int? id}) async {
    path = p;
    body = b;
  }
}

void main() {
  testWidgets('ajoute un lien de bibliothèque', (tester) async {
    final api = FakeDocs();
    await tester.pumpWidget(MaterialApp(home: DocumentForm(api: api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lien'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Règlement');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'https://example.org',
    );
    await tester.ensureVisible(find.text('Ajouter'));
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    expect(api.path, '/api/documents/links');
    expect(api.body?['externalUrl'], 'https://example.org');
  });
}
