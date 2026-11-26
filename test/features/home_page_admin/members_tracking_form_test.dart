import 'package:asaspp_app/features/home_page_admin/data/admin_api.dart';
import 'package:asaspp_app/features/home_page_admin/presentation/pages/members_tracking_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMembers extends AdminApi {
  Map<String, dynamic>? created;
  @override
  Future<List<Map<String, dynamic>>> list(String path) async => [
    {
      'membershipId': 3,
      'firstName': 'Marie',
      'lastName': 'Test',
      'email': 'marie@example.org',
      'role': 'MEMBER',
    },
  ];
  @override
  Future<Map<String, dynamic>> createMember(Map<String, dynamic> fields) async {
    created = fields;
    return {'message': 'Invitation envoyée'};
  }
}

void main() {
  testWidgets('affiche les membres et enregistre une invitation', (
    tester,
  ) async {
    final api = FakeMembers();
    await tester.pumpWidget(MaterialApp(home: MembersTrackingForm(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('Marie Test'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Jean');
    await tester.enterText(find.byType(TextFormField).at(1), 'Dupont');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'jean@example.org',
    );
    await tester.ensureVisible(find.text('Ajouter'));
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    expect(api.created?['email'], 'jean@example.org');
    expect(api.created?['role'], 'MEMBER');
    expect(find.text('Invitation envoyée'), findsOneWidget);
  });
}
