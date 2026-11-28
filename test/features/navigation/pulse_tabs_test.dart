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
    testWidgets('Accueil et Services à largeur mobile en $brightness', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.runAsync(_loadCaptureFonts);
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      final api = ApiClient(AuthStorage());
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            final Object? data = switch (request.path) {
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
      expect(find.text('Actualités du club'), findsOneWidget);
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
