class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'FITCITY_API_BASE_URL',
    defaultValue: 'http://localhost:8081',
  );
}
