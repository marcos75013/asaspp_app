import 'package:asaspp_app/features/context/data/models/mobile_association_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads branding and enabled modules from deployed mobile context', () {
    final association = MobileAssociationModel.fromJson({
      'id': 14,
      'name': 'Association culturelle',
      'logoUrl': '/logos/14.png',
      'navigationImageUrl': '/navigation-images/14.png',
      'role': 'MEMBER',
      'modules': ['EVENTS', 'PHOTO_GALLERY'],
    });

    expect(association.associationId, 14);
    expect(association.associationName, 'Association culturelle');
    expect(association.logoUrl, '/logos/14.png');
    expect(association.navigationImageUrl, '/navigation-images/14.png');
    expect(association.modules, ['EVENTS', 'PHOTO_GALLERY']);
  });

  test('accepts legacy navigation icon field', () {
    final association = MobileAssociationModel.fromJson({
      'id': 2,
      'name': 'Club',
      'navigationIconUrl': '/navigation-images/old.png',
    });
    expect(association.navigationImageUrl, '/navigation-images/old.png');
  });
}
