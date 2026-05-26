class AppConfig {
  AppConfig._();

  /// Environnement de l'application.
  ///
  /// Valeurs possibles :
  /// - local
  /// - android
  /// - prod
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'local',
  );

  static String get backendBaseUrl {
    switch (environment) {
      case 'android':
        return 'http://10.0.2.2:8080';

      case 'prod':
        return 'https://ton-api-production.com';
      case 'device':
        return 'http://10.46.36.233:8080';

      case 'local':
      default:
        return 'http://localhost:8080';
    }
  }

  static String get apiBaseUrl {
    return '$backendBaseUrl/api';
  }

  static String buildBackendUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    if (path.startsWith('/')) {
      return '$backendBaseUrl$path';
    }

    return '$backendBaseUrl/$path';
  }
}
