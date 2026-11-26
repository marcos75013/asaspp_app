import 'package:asaspp_app/features/home_page_admin/data/admin_api.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/pages/create_album_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAlbum extends AdminApi {
  Map<String, dynamic>? body;
  @override
  Future<int> createAlbum(Map<String, dynamic> fields) async {
    body = fields;
    return 4;
  }
}

void main() {
  testWidgets('crée un album avec son titre', (tester) async {
    final api = FakeAlbum();
    await tester.pumpWidget(MaterialApp(home: CreateAlbumForm(api: api)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Sortie');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(api.body?['title'], 'Sortie');
    expect(api.body?['published'], true);
  });
}
