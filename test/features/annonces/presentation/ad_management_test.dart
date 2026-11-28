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
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            if (request.method == 'PATCH') {
              expect(request.path, '/api/marketplace/1/status');
              final status = request.queryParameters['status'] as String;
              statusChanges.add(status);
              own['status'] = status;
            }
            final data = switch (request.path) {
              '/api/marketplace' => [Map.of(own), other],
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

      await tap(find.text('Mon détendeur'));
      await tap(find.text('Mettre en pause'));
      expect(find.text('En pause'), findsOneWidget);
      await tap(find.byTooltip('Retour aux annonces'));
      expect(find.text('En pause'), findsOneWidget);

      await tap(find.text('Mon détendeur'));
      await tap(find.text('Remettre en ligne'));
      expect(find.text('En ligne'), findsOneWidget);
      await tap(find.text('Marquer comme vendue'));
      expect(find.text('Vendue'), findsOneWidget);
      await tap(find.byTooltip('Retour aux annonces'));
      expect(find.text('Vendue'), findsOneWidget);
      expect(statusChanges, ['CLOSED', 'ACTIVE', 'SOLD']);
      expect(tester.takeException(), isNull);
    });
  }
}
