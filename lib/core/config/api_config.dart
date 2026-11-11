class ApiConfig {
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  final String baseUrl;

  const ApiConfig({this.baseUrl = defaultBaseUrl});

  String resolveUrl(String url) {
    final value = url.trim();
    if (value.isEmpty || Uri.tryParse(value)?.hasScheme == true) {
      return value;
    }

    final normalizedBaseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final relativePath = value.startsWith('/') ? value.substring(1) : value;

    return Uri.parse(normalizedBaseUrl).resolve(relativePath).toString();
  }
}
