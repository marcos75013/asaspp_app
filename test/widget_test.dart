import 'package:asaspp_app/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiClient', () {
    test('targets the configured development backend', () {
      expect(
        Uri.parse(ApiClient.baseUrl),
        Uri.parse('http://192.168.1.36:8080'),
      );
    });
  });
}
