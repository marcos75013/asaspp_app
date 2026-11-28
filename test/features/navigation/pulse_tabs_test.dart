import 'package:asaspp_app/core/theme/pulse_appearance.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/core/theme/pulse_theme.dart';
import 'package:asaspp_app/features/context/cubit/context_cubit.dart';
import 'package:asaspp_app/features/context/cubit/context_state.dart';
import 'package:asaspp_app/features/context/data/models/mobile_context_model.dart';
import 'package:asaspp_app/features/context/data/services/mobile_context_api_service.dart';
import 'package:asaspp_app/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _DemoContext extends ContextCubit {
  _DemoContext()
    : super(
        contextApiService: MobileContextApiService(ApiClient(AuthStorage())),
        authStorage: AuthStorage(),
      ) {
    emit(
      ContextState(
        status: ContextStatus.loaded,
        context: MobileContextModel.fromJson({
          'user': {'id': 1, 'firstName': 'Camille', 'lastName': 'Martin'},
          'associations': [
            {
              'id': 1,
              'name': 'Club Pulse',
              'role': 'ADMIN',
              'modules': [
                'QUIZ',
                'DOCUMENT_LIBRARY',
                'EVENTS',
                'CLUB_COMMUNICATION',
                'CARPOOLING',
                'PHOTO_GALLERY',
                'MARKETPLACE',
              ],
            },
          ],
        }),
      ),
    );
  }
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Parcours Pulse à largeur mobile en $brightness', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.runAsync(_loadCaptureFonts);
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final api = ApiClient(AuthStorage());
      Map<String, dynamic>? publishedAd;
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            if (request.method == 'POST' &&
                request.path == '/api/marketplace') {
              publishedAd = {
                ...request.data as Map<String, dynamic>,
                'id': 22,
                'createdAt': '2026-11-28T12:00:00Z',
              };
              handler.resolve(
                Response(requestOptions: request, data: publishedAd),
              );
              return;
            }
            final Object? data = switch (request.path) {
              '/api/marketplace' => [
                if (publishedAd != null) publishedAd!,
                {
                  'id': 20,
                  'type': 'SALE',
                  'title': 'Masque de plongée',
                  'description': 'Masque en bon état.',
                  'price': 25.50,
                  'authorFirstName': 'Camille',
                  'authorEmail': 'membre@example.test',
                  'images': [
                    {'url': 'https://example.test/verso.jpg', 'position': 1},
                    {'url': 'https://example.test/recto.jpg', 'position': 0},
                  ],
                  'favorite': true,
                },
                {'id': 21, 'type': 'GIFT', 'title': 'Palmes à donner'},
              ],
              '/api/gallery' => [
                {
                  'id': 19,
                  'title': 'Sortie en fosse',
                  'outingDate': '2026-11-26',
                  'photos': [
                    {'url': 'https://example.test/photo-1.jpg', 'position': 0},
                    {'url': 'https://example.test/photo-2.jpg', 'position': 1},
                  ],
                },
                {
                  'id': 18,
                  'title': 'Album du club',
                  'outingDate': '2026-11-14',
                },
              ],
              '/api/mobile/trainings' => {
                'last': true,
                'content': [
                  {
                    'id': 51,
                    'title': 'Séance piscine',
                    'startDate': '2099-06-08T19:00:00',
                  },
                ],
              },
              '/api/mobile/trainings/51/participants' => <dynamic>[],
              '/api/mobile/events' => {
                'content': [
                  {
                    'id': 42,
                    'title': 'Sortie en mer',
                    'location': 'Port du club',
                    'category': 'Mer',
                    'startDate': '2099-06-08T09:00:00',
                    'goingCount': 8,
                  },
                ],
              },
              '/api/mobile/messages' => [
                {
                  'id': 7,
                  'title': 'Préparer la sortie',
                  'content': 'Rendez-vous au port avec votre matériel.',
                  'signature': 'Le bureau',
                },
              ],
              '/api/mobile/association/about' => {
                'associationId': 1,
                'associationName': 'Club Pulse',
                'presentation': {
                  'configured': true,
                  'title': 'Qui sommes-nous',
                  'introduction':
                      'Nous réunissons les passionnés de sports nautiques.',
                  'activities': ['Plongée', 'Natation'],
                  'values': [
                    {
                      'title': 'Entraide',
                      'text': 'On avance ensemble.',
                      'icon': 'GROUP',
                    },
                  ],
                },
                'organization': {
                  'members': [
                    {'id': 5, 'name': 'Camille Martin'},
                    {'id': 6, 'name': 'Alex Dupont'},
                  ],
                  'sections': [
                    {
                      'id': 'BUREAU',
                      'title': 'Bureau',
                      'positions': [
                        {'id': 'a', 'title': 'Présidence', 'membershipId': 5},
                      ],
                    },
                    {
                      'id': 'ENCADREMENT',
                      'title': 'Moniteurs',
                      'positions': [
                        {'id': 'b', 'title': 'Encadrement', 'membershipId': 6},
                      ],
                    },
                  ],
                },
              },
              _ => null,
            };
            if (data == null) {
              handler.reject(DioException(requestOptions: request));
            } else {
              handler.resolve(Response(requestOptions: request, data: data));
            }
          },
        ),
      );
      final cubit = _DemoContext();
      addTearDown(cubit.close);
      final capture = GlobalKey();
      final appearance = PulseAppearance();
      addTearDown(appearance.dispose);
      await tester.pumpWidget(
        RepaintBoundary(
          key: capture,
          child: MaterialApp(
            theme: PulseTheme.build(brightness),
            debugShowCheckedModeBanner: false,
            home: BlocProvider<ContextCubit>.value(
              value: cubit,
              child: PulseAppearanceScope(
                appearance: appearance,
                child: MainScaffold(apiClient: api),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Salut, Camille !'), findsOneWidget);
      expect(find.text('Club Pulse'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.text('Sortie en mer'), findsOneWidget);
      void expectCentered(int tab) {
        final bar = tester.getRect(find.byType(CircleNavBar));
        final icon = tester.getCenter(find.byType(AssociationNavigationIcon));
        expect(icon.dx, closeTo(bar.left + bar.width * (tab + .5) / 5, 1));
      }

      expectCentered(0);
      await _capture(tester, capture, 'accueil-${brightness.name}');
      await tester.scrollUntilVisible(
        find.text('Préparer la sortie'),
        160,
        scrollable: find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first,
      );
      expect(find.text('Préparer la sortie'), findsOneWidget);
      await _capture(tester, capture, 'accueil-actualites-${brightness.name}');
      await tester.tap(find.text('Agenda'));
      await tester.pumpAndSettle();
      expectCentered(1);
      await tester.tap(find.text('Séance piscine'));
      await tester.pumpAndSettle();
      expect(find.text('Participants'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Séance piscine'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Salut, Camille !'), findsOneWidget);
      await tester.tap(find.text('Services'));
      await tester.pumpAndSettle();
      expect(find.text('Apprendre et progresser'), findsOneWidget);
      expect(find.text('Vie pratique'), findsOneWidget);
      expectCentered(3);
      expect(find.text('Club Pulse'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _capture(tester, capture, 'services-${brightness.name}');
      await tester.tap(find.text('Club'));
      await tester.pumpAndSettle();
      expect(find.text('À la une'), findsOneWidget);
      expect(find.text('Préparer la sortie'), findsOneWidget);
      await tester.tap(find.text('Préparer la sortie'));
      await tester.pumpAndSettle();
      expect(find.text('— Le bureau'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Galerie'));
      await tester.pumpAndSettle();
      expect(find.text('Galerie'), findsOneWidget);
      expect(find.text('2 albums'), findsOneWidget);
      await _capture(tester, capture, 'galerie-${brightness.name}');
      await tester.enterText(find.byType(TextField), 'introuvable');
      await tester.pumpAndSettle();
      expect(
        find.text('Aucun album ne correspond aux filtres.'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Réinitialiser les filtres'));
      await tester.pumpAndSettle();
      expect(find.text('Sortie en fosse'), findsOneWidget);
      await tester.tap(find.text('Sortie en fosse'));
      await tester.pumpAndSettle();
      expect(find.text('Les meilleurs moments'), findsOneWidget);
      expect(find.text('2 photos'), findsOneWidget);
      await _capture(tester, capture, 'album-${brightness.name}');
      await tester.tap(find.bySemanticsLabel('Ouvrir la photo 2'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Les meilleurs moments'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Album du club'));
      await tester.pumpAndSettle();
      expect(find.text('Aucune photo dans cet album.'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annonces'));
      await tester.pumpAndSettle();
      expect(find.text('Leboncourant'), findsOneWidget);
      expect(find.text('Dernières annonces'), findsOneWidget);
      expect(find.text('Palmes à donner'), findsOneWidget);
      expect(find.text('Publier une annonce'), findsOneWidget);
      await _capture(tester, capture, 'annonces-${brightness.name}');
      await tester.tap(find.text('Favoris'));
      await tester.pumpAndSettle();
      expect(find.text('Palmes à donner'), findsNothing);
      await tester.tap(find.text('Masque de plongée'));
      await tester.pumpAndSettle();
      expect(find.text('25,50 €'), findsOneWidget);
      expect(find.text('Le vendeur'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
      await tester.tap(find.byTooltip('Photo suivante'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2'), findsOneWidget);
      await tester.tapAt(tester.getCenter(find.byType(PageView)));
      await tester.pumpAndSettle();
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      final center = tester.getCenter(find.byType(InteractiveViewer));
      final left = await tester.startGesture(
        center - const Offset(25, 0),
        pointer: 1,
      );
      final right = await tester.startGesture(
        center + const Offset(25, 0),
        pointer: 2,
      );
      await left.moveBy(const Offset(-50, 0));
      await right.moveBy(const Offset(50, 0));
      await left.up();
      await right.up();
      await tester.pumpAndSettle();
      expect(
        viewer.transformationController!.value.getMaxScaleOnAxis(),
        greaterThan(1),
      );
      await tester.tap(find.byTooltip('Fermer le plein écran'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2'), findsOneWidget);
      await tester.drag(find.byType(PageView), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(find.text('1 / 2'), findsOneWidget);
      await _capture(tester, capture, 'annonce-${brightness.name}');
      await tester.ensureVisible(find.text('Contacter le vendeur'));
      await tester.tap(find.text('Contacter le vendeur'));
      await tester.pumpAndSettle();
      expect(find.text('membre@example.test'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Retour aux annonces'));
      await tester.pumpAndSettle();
      expect(find.text('Palmes à donner'), findsNothing);
      await tester.tap(find.text('Tous'));
      await tester.pumpAndSettle();
      expect(find.text('Palmes à donner'), findsOneWidget);
      await tester.tap(find.text('Publier une annonce'));
      await tester.pumpAndSettle();
      expect(find.text('Nouvelle annonce'), findsOneWidget);
      await _capture(tester, capture, 'publication-${brightness.name}');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Don'));
      await tester.pumpAndSettle();
      expect(find.text('Prix (€)'), findsNothing);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Nouvelle annonce test',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Description de test',
      );
      await tester.ensureVisible(find.text('Publier mon annonce'));
      await tester.tap(find.text('Publier mon annonce'));
      await tester.pumpAndSettle();
      expect(publishedAd?['price'], 0);
      expect(find.text('Nouvelle annonce test'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('À la une'), findsOneWidget);
      await _capture(tester, capture, 'club-${brightness.name}');
      await tester.tap(find.text('Qui sommes-nous'));
      await tester.pumpAndSettle();
      expect(find.text('Bureau'), findsOneWidget);
      expect(find.text('Camille Martin'), findsOneWidget);
      await _capture(tester, capture, 'presentation-${brightness.name}');
      await tester.scrollUntilVisible(find.text('Alex Dupont'), 160);
      expect(find.text('Moniteurs'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _capture(tester, capture, 'organigramme-${brightness.name}');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Camille Martin'), findsOneWidget);
      expect(find.text('Administrateur'), findsOneWidget);
      expect(find.text('Apparence'), findsOneWidget);
      expect(find.text('Espace admin'), findsOneWidget);
      expectCentered(4);
      expect(tester.takeException(), isNull);
      await _capture(tester, capture, 'profil-${brightness.name}');
    });
  }
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  const output = String.fromEnvironment('PULSE_CAPTURE_DIR');
  if (output.isEmpty) return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    try {
      final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      await File('$output/$name.png').writeAsBytes(png.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

Future<void> _loadCaptureFonts() async {
  for (final (family, path) in [
    ('Roboto', const String.fromEnvironment('PULSE_TEXT_FONT')),
    ('MaterialIcons', const String.fromEnvironment('PULSE_ICON_FONT')),
  ]) {
    if (path.isEmpty) continue;
    final bytes = await File(path).readAsBytes();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}
