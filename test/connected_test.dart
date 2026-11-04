import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asaspp_app/features/context/cubit/context_cubit.dart';
import 'package:asaspp_app/features/connected/presentation/club_shell.dart';
import '../tool/visual_preview.dart' as preview;
import 'dart:typed_data';
import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/features/connected/data/club_api.dart';
import 'package:asaspp_app/features/connected/presentation/club_widgets.dart';
import 'package:asaspp_app/features/connected/presentation/events_page.dart';
import 'package:asaspp_app/features/connected/presentation/quiz_pages.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FixtureAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions) handler;
  FixtureAdapter(this.handler);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handler(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody response(dynamic data, [int status = 200]) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

Json event({String? status}) => {
  'id': 12,
  'published': true,
  'title': 'Sortie du samedi',
  'category': 'Sortie',
  'description': 'Un rendez-vous au bord de l’eau.',
  'location': 'Le port',
  'startDate': '2026-11-14T09:00:00',
  'endDate': '2026-11-14T17:00:00',
  'goingCount': 8,
  'capacity': 8,
  'waitlistedCount': status == 'WAITLISTED' ? 1 : 0,
  'currentUserStatus': status,
};
Widget app(Widget page) => MaterialApp(theme: connectedTheme(), home: page);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'dashboard and club navigation render on a phone without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(
          BlocProvider<ContextCubit>(
            create: (_) => preview.PreviewContextCubit()..loadContext(),
            child: ClubShell(
              apiFactory: (id) => ClubApi(
                id,
                client: Dio()..httpClientAdapter = preview.PreviewAdapter(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bonjour Camille 🤿'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Mon club'));
      await tester.pumpAndSettle();
      expect(find.text('Votre club'), findsOneWidget);
      expect(find.text('Espace administrateur'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Mon profil'));
      await tester.pumpAndSettle();
      expect(find.text('Camille Martin'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'association-bound API keeps the selected tenant and bearer token',
    () async {
      final storage = AuthStorage();
      await storage.saveToken('test-token');
      await storage.saveActiveAssociationId(99);
      final dio = ApiClient(storage).dio;
      dio.httpClientAdapter = FixtureAdapter((options) async {
        expect(options.headers['Authorization'], 'Bearer test-token');
        expect(options.headers['X-Association-Id'], '7');
        expect(options.queryParameters['page'], 2);
        expect(options.queryParameters['title'], 'sortie');
        return response({
          'content': [event()],
          'last': true,
        });
      });
      final result = await ClubApi(
        7,
        client: dio,
      ).events(page: 2, query: 'sortie');
      expect(records(result['content']).single['id'], 12);
    },
  );

  testWidgets(
    'full event displays server waitlist response after participation',
    (tester) async {
      final dio = Dio();
      dio.httpClientAdapter = FixtureAdapter((options) async {
        expect(options.path, '/api/events/12/participation');
        expect(options.method, 'PUT');
        expect(options.data, {'status': 'GOING'});
        return response(event(status: 'WAITLISTED'));
      });
      await tester.pumpWidget(
        app(
          EventDetails(
            api: ClubApi(7, client: dio),
            event: event(),
            carpooling: false,
          ),
        ),
      );
      await tester.tap(find.text('Je participe'));
      await tester.pumpAndSettle();
      expect(
        find.text('Votre demande est enregistrée sur la liste d’attente.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'agenda exposes retry after network failure and then real empty state',
    (tester) async {
      var calls = 0;
      final dio = Dio();
      dio.httpClientAdapter = FixtureAdapter((options) async {
        calls++;
        return calls == 1
            ? response({}, 503)
            : response({'content': [], 'last': true});
      });
      await tester.pumpWidget(
        app(
          Scaffold(
            body: ConnectedEvents(
              api: ClubApi(7, client: dio),
              carpooling: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Agenda indisponible'), findsOneWidget);
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      expect(find.text('La suite se prépare'), findsOneWidget);
    },
  );

  testWidgets(
    'quiz submits original indexes after server shuffling and shows persisted score',
    (tester) async {
      final quiz = {
        'id': 4,
        'title': 'Sécurité',
        'questions': [
          {
            'index': 8,
            'text': 'Que vérifier ?',
            'choices': [
              {'index': 3, 'text': 'Le matériel'},
              {'index': 0, 'text': 'Rien'},
            ],
          },
        ],
      };
      final dio = Dio();
      dio.httpClientAdapter = FixtureAdapter((options) async {
        expect(options.path, '/api/mobile/quizzes/4/attempts');
        expect(options.method, 'POST');
        expect(options.data, {
          'answers': [
            {'questionIndex': 8, 'choiceIndex': 3},
          ],
        });
        return response({
          'score': 100,
          'passed': true,
          'correctAnswers': 1,
          'totalQuestions': 1,
          'corrections': [
            {
              'questionIndex': 8,
              'correctChoiceIndex': 3,
              'correct': true,
              'explanation': 'Avant chaque sortie.',
            },
          ],
        });
      });
      await tester.pumpWidget(
        app(
          QuizRun(
            api: ClubApi(7, client: dio),
            quiz: quiz,
          ),
        ),
      );
      await tester.tap(find.text('Le matériel'));
      await tester.pump();
      await tester.tap(find.text('Voir mon résultat'));
      await tester.pumpAndSettle();
      expect(find.text('100 %'), findsOneWidget);
      expect(find.text('Votre résultat a été enregistré.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('event card supports narrow screens and large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: connectedTheme(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: EventCard(
                event: event(status: 'WAITLISTED'),
                api: ClubApi(7),
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
