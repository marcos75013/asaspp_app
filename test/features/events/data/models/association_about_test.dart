import 'package:asaspp_app/features/events/data/models/association_about.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses membership ids and preserves hierarchy', () {
    final about = AssociationAbout.fromJson({
      'associationId': 12,
      'associationName': 'Club test',
      'presentation': {
        'configured': true,
        'title': 'Notre club',
        'introduction': 'Bonjour',
        'values': [
          {'title': 'Entraide', 'text': 'Ensemble', 'icon': 'GROUP'},
        ],
        'activities': ['Activité B', 'Activité A'],
      },
      'organization': {
        'positions': [
          {
            'id': 'root',
            'title': 'Présidence',
            'membershipId': 21,
            'parentId': null,
          },
          {
            'id': 'child',
            'title': 'Formation',
            'membershipId': 22,
            'parentId': 'root',
          },
        ],
        'members': [
          {'id': 21, 'name': 'Camille Martin', 'avatarUrl': null},
          {
            'id': 22,
            'name': 'Alex Dupont',
            'avatarUrl': '/profile-images/test',
          },
        ],
      },
    });
    expect(about.presentation.activities, ['Activité B', 'Activité A']);
    expect(about.orderedPositions.map((position) => position.depth), [0, 1]);
    expect(about.members[about.positions[1].membershipId]?.name, 'Alex Dupont');
  });

  test('accepts an unconfigured association without demo content', () {
    final about = AssociationAbout.fromJson({
      'associationId': 8,
      'associationName': 'Autre association',
      'presentation': {'configured': false, 'values': [], 'activities': []},
      'organization': {'positions': [], 'members': []},
    });
    expect(about.presentation.configured, isFalse);
    expect(about.presentation.values, isEmpty);
    expect(about.orderedPositions, isEmpty);
  });
}
