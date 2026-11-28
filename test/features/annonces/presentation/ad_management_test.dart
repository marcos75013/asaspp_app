import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/core/theme/pulse_theme.dart';
import 'package:asaspp_app/features/annonces/data/services/mobile_ads_api_service.dart';
import 'package:asaspp_app/features/annonces/presentation/pages/ads_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('only the owner can manage visibility in ${brightness.name}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final api = ApiClient(AuthStorage());
      final own = <String, dynamic>{
        'id': 1,
        'title': 'Mon détendeur',
        'type': 'SALE',
        'price': 10,
        'description': 'À récupérer au club.',
        'images': [
          {'id': 4, 'url': 'https://example.test/annonce.jpg', 'position': 0},
        ],
        'status': 'ACTIVE',
        'active': true,
        'owner': true,
      };
      final other = <String, dynamic>{
        ...own,
        'id': 2,
        'title': 'Les palmes de Camille',
        'owner': false,
      };
      final statusChanges = <String>[];
      var deleted = false;
      var removedPhoto = false;
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            if (request.method == 'PUT') {
              expect(request.path, '/api/marketplace/1');
              own.addAll(request.data as Map<String, dynamic>);
            }
            if (request.method == 'DELETE') {
              if (request.path == '/api/marketplace/1/images/4') {
                removedPhoto = true;
                own['images'] = [];
                handler.resolve(
                  Response(requestOptions: request, statusCode: 204),
                );
                return;
              }
              expect(request.path, '/api/marketplace/1');
              deleted = true;
              handler.resolve(
                Response(requestOptions: request, statusCode: 204),
              );
              return;
            }
            if (request.method == 'PATCH') {
              expect(request.path, '/api/marketplace/1/status');
              final status = request.queryParameters['status'] as String;
              statusChanges.add(status);
              own['status'] = status;
            }
            final data = switch (request.path) {
              '/api/marketplace' => [if (!deleted) Map.of(own), other],
              '/api/marketplace/1' ||
              '/api/marketplace/1/status' => Map.of(own),
              '/api/marketplace/2' => other,
              _ => throw StateError('Unexpected route ${request.path}'),
            };
            handler.resolve(Response(requestOptions: request, data: data));
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: PulseTheme.build(brightness),
          home: AdsPage(repository: MobileAdsApiService(api)),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> tap(Finder finder) async {
        await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      await tap(find.text('Les palmes de Camille'));
      expect(find.text('Gérer mon annonce'), findsNothing);
      await tap(find.byTooltip('Retour aux annonces'));

      await tap(find.text('Mes annonces'));
      expect(find.text('Les palmes de Camille'), findsNothing);
      expect(find.text('Gérer'), findsOneWidget);
      await tap(find.text('Gérer'));
      expect(find.text('Gérer mon annonce').hitTestable(), findsOneWidget);
      await tap(find.text('Modifier mon annonce'));
      final fields = find.byType(TextFormField);
      expect(find.text('Mon détendeur'), findsOneWidget);
      expect(find.text('1/5 photos'), findsOneWidget);
      await tap(find.byTooltip('Retirer la photo publiée 1'));
      await tester.enterText(fields.at(0), 'Détendeur révisé');
      await tester.enterText(fields.at(1), '15,50');
      await tester.enterText(fields.at(2), 'Description actualisée');
      await tap(find.text('Enregistrer les modifications'));
      expect(removedPhoto, isTrue);
      expect(own['price'], 15.50);
      expect(find.text('Description actualisée'), findsOneWidget);
      await tap(find.byTooltip('Retour aux annonces'));
      expect(find.text('Détendeur révisé'), findsOneWidget);
      expect(find.text('Les palmes de Camille'), findsNothing);
      await tap(find.text('Tous'));
      await tap(find.text('Détendeur révisé'));
      await tap(find.text('Mettre en pause'));
      expect(find.text('En pause'), findsOneWidget);
      await tap(find.byTooltip('Retour aux annonces'));
      expect(find.text('En pause'), findsOneWidget);

      await tap(find.text('Détendeur révisé'));
      await tap(find.text('Remettre en ligne'));
      expect(find.text('En ligne'), findsOneWidget);
      await tap(find.text('Marquer comme vendue'));
      expect(find.text('Supprimer l’annonce vendue ?'), findsOneWidget);
      await tap(find.text('Annuler'));
      expect(deleted, isFalse);
      expect(find.text('En ligne'), findsOneWidget);
      await tap(find.text('Marquer comme vendue'));
      await tap(find.text('Supprimer'));
      expect(deleted, isTrue);
      expect(find.text('Détendeur révisé'), findsNothing);
      expect(find.text('Les palmes de Camille'), findsOneWidget);
      expect(statusChanges, ['CLOSED', 'ACTIVE']);
      expect(tester.takeException(), isNull);
    });
  }
}
