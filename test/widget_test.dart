import 'package:asaspp_app/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('builds the local API URL', () {
      expect(AppConfig.apiBaseUrl, 'http://localhost:8080/api');
    });

    test('keeps absolute URLs unchanged', () {
      const url = 'https://example.com/photo.jpg';
      expect(AppConfig.buildBackendUrl(url), url);
    });

    test('builds an absolute backend URL from a path', () {
      expect(
        AppConfig.buildBackendUrl('/uploads/photo.jpg'),
        'http://localhost:8080/uploads/photo.jpg',
      );
    });
  });
}
