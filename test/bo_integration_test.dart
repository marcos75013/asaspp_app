import 'package:asaspp_app/core/data/association_repository.dart';
import 'package:asaspp_app/core/theme/app_theme.dart';
import 'package:asaspp_app/features/bo/bo_widgets.dart';
import 'package:asaspp_app/features/bo/bo_members.dart';
import 'package:asaspp_app/features/bo/bo_events.dart';
import 'package:asaspp_app/features/bo/bo_quiz.dart';
import 'package:asaspp_app/features/context/cubit/context_cubit.dart';
import 'package:asaspp_app/features/context/cubit/context_state.dart';
import 'package:asaspp_app/features/context/data/models/mobile_context_model.dart';
import 'package:asaspp_app/features/context/data/models/mobile_association_model.dart';
import 'package:asaspp_app/features/context/data/models/association_role.dart';
import 'package:asaspp_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/pages/home_page_admin.dart';
import 'package:asaspp_app/features/user/presentation/cubit/user_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../tool/visual_preview.dart' as preview;
import 'connected_test.dart' show FixtureAdapter, response, event;

class FixtureContext extends preview.PreviewContextCubit {
  final MobileContextModel model;
  FixtureContext(this.model);
  @override
  Future<void> loadContext() async =>
      emit(ContextState(status: ContextStatus.loaded, context: model));
}

Future<void> mount(
  WidgetTester tester,
  Widget page,
  ClubApi api, {
  bool admin = true,
  List<String> modules = const ['EVENTS', 'QUIZ'],
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final repo = AssociationRepository(injectedApi: api);
  final context = MobileContextModel(
    user: preview.previewContext.user,
    associations: [
      MobileAssociationModel(
        associationId: 1,
        associationName: 'Association test',
        role: admin ? AssociationRole.admin : AssociationRole.member,
        modules: modules,
      ),
    ],
  );
  await tester.pumpWidget(
    RepositoryProvider.value(
      value: repo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => HomeCubit(repo)),
          BlocProvider(create: (_) => UserCubit()..setContext(context)),
          BlocProvider<ContextCubit>(
            create: (_) => FixtureContext(context)..loadContext(),
          ),
        ],
        child: MaterialApp(theme: AppTheme.lightTheme, home: page),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
);
void main() {
  test(
    'all form fields are validated even when scrolled outside the viewport',
    () {
      const fields = [
        BoField('name', 'Nom', required: true),
        BoField('depth', 'Profondeur', kind: 'integer', min: 1, max: 120),
        BoField('email', 'Email', kind: 'email'),
      ];
      expect(validateBoFields(fields, {'name': null}), isNotNull);
      expect(
        validateBoFields(fields, {'name': 'Test', 'depth': 12.5}),
        isNotNull,
      );
      expect(
        validateBoFields(fields, {'name': 'Test', 'email': 'incorrect'}),
        isNotNull,
      );
      expect(
        validateBoFields(fields, {
          'name': 'Test',
          'depth': 20,
          'email': 'test@example.org',
        }),
        isNull,
      );
    },
  );
  test(
    'events pagination retains drafts for admin and validates recurrence',
    () async {
      final pages = <int>[];
      final api = ClubApi(
        37,
        client: Dio()
          ..httpClientAdapter = FixtureAdapter((request) async {
            expect(request.headers['X-Association-Id'], '37');
            final page = request.queryParameters['page'] as int;
            pages.add(page);
            return response({
              'last': page == 1,
              'content': [
                {...event(), 'id': page + 1, 'published': page == 1},
              ],
            });
          }),
      );
      final rows = await allBoEvents(api);
      expect(pages, [0, 1]);
      expect(rows.length, 2);
      expect(rows.first['published'], false);
      expect(
        validateBoEvent({
          'startDate': '2099-01-01T10:00:00',
          'recurrenceFrequency': 'WEEKLY',
        }),
        isNotNull,
      );
      expect(
        validateBoEvent({
          'startDate': '2099-01-01T10:00:00',
          'endDate': '2099-01-01T09:00:00',
        }),
        isNotNull,
      );
      expect(
        validateBoEvent({'startDate': '2099-01-01T10:00:00', 'capacity': 2.5}),
        isNotNull,
      );
      expect(
        validateBoEvent({
          'startDate': '2099-01-01T10:00:00',
          'recurrenceFrequency': 'WEEKLY',
          'recurrenceUntil': '2099-02-01',
          'recurrenceInterval': 1,
          'capacity': 12,
        }),
        isNull,
      );
    },
  );
  testWidgets('admin menu protects role and hides disabled modules', (
    tester,
  ) async {
    int calls = 0;
    final api = ClubApi(
      1,
      client: Dio()
        ..httpClientAdapter = FixtureAdapter((r) async {
          calls++;
          return response({'activityCode': 'FOOTBALL'});
        }),
    );
    await mount(tester, const HomePageAdmin(), api, admin: false);
    expect(
      find.text('Cet espace est réservé aux administrateurs.'),
      findsOneWidget,
    );
    expect(calls, 0);
    await tester.pumpWidget(const SizedBox());
    await mount(tester, const HomePageAdmin(), api, modules: []);
    expect(find.text('Suivi des membres'), findsOneWidget);
    expect(find.text('Événements'), findsNothing);
    expect(find.text('Quiz et résultats'), findsNothing);
    expect(find.text('Préparer les plongées'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'compliance verification persists then refreshes document state',
    (tester) async {
      bool verified = false;
      int loads = 0;
      final api = ClubApi(
        1,
        client: Dio()
          ..httpClientAdapter = FixtureAdapter((r) async {
            if (r.method == 'PATCH') {
              expect(r.path, '$memberBase/compliance-documents/4/verify');
              expect(r.queryParameters['verified'], true);
              verified = true;
              return response({});
            }
            expect(r.path, '$memberBase/12/compliance-documents');
            loads++;
            return response([
              {
                'id': 4,
                'type': 'LICENSE',
                'originalFilename': 'licence.pdf',
                'verified': verified,
                'expiresOn': '2099-01-01',
              },
            ]);
          }),
      );
      await mount(tester, const BoMemberDocuments(membershipId: 12), api);
      await tester.tap(find.text('Marquer vérifié'));
      await tester.pumpAndSettle();
      expect(verified, true);
      expect(loads, 2);
      expect(find.text('Retirer la vérification'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'failed verification displays error and leaves document unverified',
    (tester) async {
      final api = ClubApi(
        1,
        client: Dio()
          ..httpClientAdapter = FixtureAdapter(
            (r) async => r.method == 'PATCH'
                ? response({'message': 'Accès refusé'}, 403)
                : response([
                    {
                      'id': 4,
                      'type': 'LICENSE',
                      'originalFilename': 'licence.pdf',
                      'verified': false,
                    },
                  ]),
          ),
      );
      await mount(tester, const BoMemberDocuments(membershipId: 12), api);
      await tester.tap(find.text('Marquer vérifié'));
      await tester.pumpAndSettle();
      expect(find.text('Marquer vérifié'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'event edit uses PATCH with series scope and preserves draft state',
    (tester) async {
      RequestOptions? written;
      final api = ClubApi(
        1,
        client: Dio()
          ..httpClientAdapter = FixtureAdapter((r) async {
            if (r.method == 'PATCH') {
              written = r;
              return response({});
            }
            if (r.path == '/api/event-categories') return response([]);
            return response({'last': true, 'content': []});
          }),
      );
      final e = {
        ...event(),
        'id': 12,
        'startDate': '2099-01-01T10:00:00',
        'endDate': null,
        'published': false,
        'recurrenceSeriesId': 'series-1',
      };
      await mount(
        tester,
        Builder(
          builder: (c) => Scaffold(
            body: TextButton(
              onPressed: () => editBoEvent(c, api, event: e),
              child: const Text('Ouvrir'),
            ),
          ),
        ),
        api,
      );
      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Titre'), 'Sortie modifiée');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Cette occurrence'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cette occurrence'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cette occurrence et les suivantes').last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Enregistrer'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(written?.path, '/api/events/12');
      expect(written?.queryParameters['scope'], 'SERIES');
      expect(written?.data['published'], false);
      expect(written?.data['title'], 'Sortie modifiée');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('quiz metadata updates preserve answers and drafts', (
    tester,
  ) async {
    RequestOptions? written;
    final api = ClubApi(
      1,
      client: Dio()
        ..httpClientAdapter = FixtureAdapter((r) async {
          written = r;
          return response({});
        }),
    );
    final quiz = {
      'id': 7,
      'title': 'Sécurité',
      'description': 'Révision',
      'published': false,
      'passingScore': 80,
      'questions': [
        {
          'text': 'Avant de plonger ?',
          'explanation': 'Vérifier son matériel.',
          'choices': [
            {'text': 'Vérifier', 'correct': true},
            {'text': 'Ignorer', 'correct': false},
          ],
        },
      ],
    };
    await mount(tester, BoQuizEditor(api: api, quiz: quiz), api);
    await tester.enterText(field('Titre'), 'Sécurité en plongée');
    await tester.scrollUntilVisible(
      find.text('Enregistrer le quiz'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Enregistrer le quiz'));
    await tester.pumpAndSettle();
    expect(written?.method, 'PUT');
    expect(written?.path, '/api/quizzes/7');
    expect(written?.data['published'], false);
    expect(written?.data['questions'], quiz['questions']);
  });
}
