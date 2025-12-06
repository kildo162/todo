class ApiConfig {
  static String baseUrl = const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.khanhnd.com',
  );

  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  static String getBaseUrl() => baseUrl;
}
