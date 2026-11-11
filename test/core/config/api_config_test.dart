import 'package:asaspp_app/core/config/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = ApiConfig(baseUrl: 'https://api.multiasso.test');

  group('ApiConfig.resolveUrl', () {
    test('resolves an absolute backend path', () {
      expect(
        config.resolveUrl('/uploads/avatars/member.png'),
        'https://api.multiasso.test/uploads/avatars/member.png',
      );
    });

    test('resolves a relative backend path', () {
      expect(
        config.resolveUrl('uploads/avatars/member.png'),
        'https://api.multiasso.test/uploads/avatars/member.png',
      );
    });

    test('keeps an external URL unchanged', () {
      const externalUrl = 'https://cdn.example.test/member.png';

      expect(config.resolveUrl(externalUrl), externalUrl);
    });

    test('keeps an empty URL unchanged', () {
      expect(config.resolveUrl(''), isEmpty);
    });
  });
}
