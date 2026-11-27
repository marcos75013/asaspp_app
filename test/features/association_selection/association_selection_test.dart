import 'package:asaspp_app/core/network/api_client.dart';
import 'package:asaspp_app/core/storage/auth_storage.dart';
import 'package:asaspp_app/features/association_selection/presentation/pages/association_selection_page.dart';
import 'package:asaspp_app/features/context/cubit/context_cubit.dart';
import 'package:asaspp_app/features/context/data/models/association_role.dart';
import 'package:asaspp_app/features/context/data/models/mobile_context_model.dart';
import 'package:asaspp_app/features/context/data/services/mobile_context_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ContextApi extends MobileContextApiService {
  _ContextApi(this.fixture) : super(ApiClient(AuthStorage()));
  final MobileContextModel fixture;

  @override
  Future<MobileContextModel> getContext() async => fixture;
}

void main() {
  testWidgets(
    'switching club persists the id and reloads its identity and permissions',
    (tester) async {
      SharedPreferences.setMockInitialValues({'active_association_id': 1});
      final fixture = MobileContextModel.fromJson({
        'user': {'id': 42},
        'associations': [
          {
            'id': 1,
            'name': 'Club A',
            'role': 'ADMIN',
            'modules': ['QUIZ'],
          },
          {
            'id': 2,
            'name': 'Club B',
            'role': 'MEMBER',
            'modules': ['DOCUMENT_LIBRARY'],
          },
        ],
        'activeAssociation': {'id': 1, 'name': 'Club A', 'role': 'ADMIN'},
      });
      final router = GoRouter(
        initialLocation: '/select',
        routes: [
          GoRoute(
            path: '/select',
            builder: (_, _) => AssociationSelectionPage(mobileContext: fixture),
          ),
          GoRoute(
            path: '/home',
            builder: (_, _) => const Scaffold(body: Text('Accueil du club')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ListTile>(find.widgetWithText(ListTile, 'Club A'))
            .selected,
        isTrue,
      );
      await tester.tap(find.text('Club B'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      expect(find.text('Accueil du club'), findsOneWidget);
      expect(await AuthStorage().getActiveAssociationId(), 2);

      final updated = MobileContextModel.fromJson({
        'user': {'id': 42},
        'associations': [
          {
            'id': 2,
            'name': 'Club B',
            'logoUrl': '/club-b.png',
            'role': 'MEMBER',
            'modules': ['DOCUMENT_LIBRARY'],
          },
        ],
      });
      final cubit = ContextCubit(
        contextApiService: _ContextApi(updated),
        authStorage: AuthStorage(),
      );
      addTearDown(cubit.close);
      await cubit.loadContext();
      final association = cubit.state.context?.currentAssociation;
      expect(association?.associationId, 2);
      expect(association?.logoUrl, '/club-b.png');
      expect(association?.role, AssociationRole.member);
      expect(association?.modules, ['DOCUMENT_LIBRARY']);
    },
  );
}
