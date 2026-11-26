import 'package:asaspp_app/features/context/data/models/association_role.dart';
import 'package:asaspp_app/features/context/data/models/mobile_association_model.dart';
import 'package:asaspp_app/features/context/data/models/mobile_context_model.dart';
import 'package:asaspp_app/features/context/data/models/mobile_user_model.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/widgets/admin_access_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const user = MobileUserModel(
  id: 1,
  email: 'a@b.test',
  firstName: 'A',
  lastName: 'B',
);
const admin = MobileAssociationModel(
  associationId: 1,
  associationName: 'A',
  role: AssociationRole.admin,
  modules: [],
);
const member = MobileAssociationModel(
  associationId: 2,
  associationName: 'B',
  role: AssociationRole.member,
  modules: [],
);
const mobileContext = MobileContextModel(
  user: user,
  associations: [admin, member],
  activeAssociation: admin,
);

void main() {
  test(
    'vérifie le rôle de l’association sélectionnée et refuse les associations inconnues',
    () {
      expect(isAssociationAdmin(mobileContext, 1), isTrue);
      expect(isAssociationAdmin(mobileContext, 2), isFalse);
      expect(isAssociationAdmin(mobileContext, 99), isFalse);
    },
  );
  testWidgets('un membre ne voit pas la page admin', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminAccessGuard(
          checkAccess: () async => false,
          child: const Text('Contenu admin'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Contenu admin'), findsNothing);
    expect(find.textContaining('réservé aux administrateurs'), findsOneWidget);
  });
  testWidgets('un admin accède à la page et une erreur ne donne pas accès', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminAccessGuard(
          checkAccess: () async => true,
          child: const Text('Contenu admin'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Contenu admin'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: AdminAccessGuard(
          key: const ValueKey('error'),
          checkAccess: () async => throw Exception(),
          child: const Text('Contenu admin'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Contenu admin'), findsNothing);
    expect(find.text('Réessayer'), findsOneWidget);
  });
}
