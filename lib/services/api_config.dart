class ApiConfig {
  static const String _defaultBaseUrl = 'https://novelina-worker.24111814026.workers.dev';

  static const String baseUrl =
      String.fromEnvironment('NOVELINA_API_URL', defaultValue: _defaultBaseUrl);

  static Uri resolve(String path) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final sanitizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$sanitizedBase/$normalizedPath');
  }
}
