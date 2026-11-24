import 'package:asaspp_app/features/messages/data/models/mobile_message_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a mobile message response', () {
    final message = MobileMessageModel.fromJson({
      'id': 7,
      'title': 'Sortie club',
      'content': 'Rendez-vous samedi matin.',
      'signature': 'Le bureau',
      'createdByAvatarUrl':
          '/profile-images/11111111-1111-1111-1111-111111111111',
      'authorFirstName': 'Alice',
      'authorLastName': 'Martin',
      'createdAt': '2026-11-11T10:30:00',
    });

    expect(message.id, 7);
    expect(message.title, 'Sortie club');
    expect(message.content, 'Rendez-vous samedi matin.');
    expect(message.signature, 'Le bureau');
    expect(
      message.authorAvatarUrl,
      '/profile-images/11111111-1111-1111-1111-111111111111',
    );
    expect(message.authorName, 'Alice Martin');
    expect(message.createdAt, DateTime(2026, 11, 11, 10, 30));
  });

  test('supports a missing author name', () {
    final message = MobileMessageModel.fromJson({
      'id': 8,
      'title': 'Information',
      'content': 'Le local sera fermé.',
      'createdAt': '2026-11-11T11:00:00',
    });

    expect(message.authorName, isEmpty);
  });
}
