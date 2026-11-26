import 'package:asaspp_app/features/annonces/presentation/data/models/ad_model.dart';
import 'package:asaspp_app/features/annonces/presentation/pages/ad_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('the back button returns from the ad detail to the list', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final ad = AdModel(
      id: '1',
      title: 'Annonce test',
      description: 'Description',
      image: '',
      price: 10,
      sellerName: 'Membre',
      sellerAvatar: '',
      createdAt: DateTime(2026),
      type: AdType.vente,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => AdDetailPage(ad: ad)),
              ),
              child: const Text('Liste des annonces'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Liste des annonces'));
    await tester.pumpAndSettle();
    expect(find.text('Annonce test'), findsOneWidget);
    await tester.tap(find.byTooltip('Retour aux annonces'));
    await tester.pumpAndSettle();
    expect(find.text('Liste des annonces'), findsOneWidget);
    expect(find.text('Annonce test'), findsNothing);
  });
}
