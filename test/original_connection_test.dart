import 'package:asaspp_app/core/data/association_repository.dart';
import 'package:asaspp_app/core/theme/app_theme.dart';
import 'package:asaspp_app/features/connected/data/club_api.dart';
import 'package:asaspp_app/features/context/cubit/context_cubit.dart';
import 'package:asaspp_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asaspp_app/features/home/data/models/next_event_model.dart';
import 'package:asaspp_app/features/user/presentation/cubit/user_cubit.dart';
import 'package:asaspp_app/main_scaffold.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../tool/visual_preview.dart' as preview;
import 'connected_test.dart' show FixtureAdapter, response, event;

void main() {
  test(
    'Original carousel preserves same-category events and server waitlist',
    () async {
      final api = ClubApi(
        1,
        client: Dio()
          ..httpClientAdapter = FixtureAdapter((request) async {
            if (request.method == 'PUT') {
              expect(request.data, {'status': 'GOING'});
              return response({...event(status: 'WAITLISTED'), 'id': 1});
            }
            return response({
              'last': true,
              'content': [
                {...event(), 'id': 1},
                {...event(), 'id': 2},
                {...event(), 'id': 3, 'published': false},
              ],
            });
          }),
      );
      final cubit = HomeCubit(AssociationRepository(injectedApi: api));
      await cubit.loadEvents();
      expect(cubit.state.nextEvents.keys, [1, 2]);
      await cubit.setParticipation(1, ParticipationStatus.going);
      expect(
        cubit.state.nextEvents[1]!.participation,
        ParticipationStatus.waitlisted,
      );
      expect(cubit.state.pending, isEmpty);
      await cubit.close();
    },
  );
  testWidgets('Original home renders on phone with connected fixtures', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = AssociationRepository(
      injectedApi: ClubApi(
        1,
        client: Dio()
          ..httpClientAdapter = FixtureAdapter(
            (request) async => response(
              request.path == '/api/events'
                  ? {
                      'last': true,
                      'content': List.generate(
                        35,
                        (i) => {
                          ...event(),
                          'id': i + 1,
                          'title': 'Une échappée en mer',
                        },
                      ),
                    }
                  : [],
            ),
          ),
      ),
    );
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: repo,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => HomeCubit(repo)..loadEvents()),
            BlocProvider(
              create: (_) => UserCubit()..setContext(preview.previewContext),
            ),
            BlocProvider<ContextCubit>(
              create: (_) => preview.PreviewContextCubit()..loadContext(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MainScaffold(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Camille'), findsWidgets);
    expect(find.text('Une échappée en mer'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
