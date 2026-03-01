/// App-wide constants for Kahu Ola
class AppConstants {
  AppConstants._();

  // App identity
  static const String appName = 'Kahu Ola';
  static const String appTagline = 'Guardian of Life';
  static const String appFullName = 'Kahu Ola - Guardian of Life';
  static const String appVersion = '1.0.0';
  static const String mapboxToken = 'pk.eyJ1Ijoibmd1eWVuaHV1bG9uZzIyIiwiYSI6ImNtbTY1dWg5NTBlNWYycXEyNWhrenRpdXcifQ.vs9tPANwLMzrrwO0NdLctQ'; // Thay bằng Key thật của bạn
  static const String mapboxStyle = 'mapbox/satellite-streets-v12';
  static const String slackWebhookUrl =
      String.fromEnvironment('SLACK_WEBHOOK_URL', defaultValue: '');
  static const String slackAlertsChannel =
      String.fromEnvironment('SLACK_ALERTS_CHANNEL', defaultValue: '#fire-alerts');
  // Organisation
  static const String orgName = 'Kahu Ola Civic Tech';
  static const String founder = 'Long Nguyen';
  static const String targetMembers = '50,000';

  // Backend base URL (Cloud Run)
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.kahuola.app');

  static const String apiVersion = 'v1';

  // Cache TTL (seconds)
  static const int alertCacheTtl = 60;
  static const int weatherCacheTtl = 300;
  static const int mapCacheTtl = 120;

  // Stale-data threshold (minutes)
  static const int staleDataThreshold = 15;

  // Bottom nav indices
  static const int navHome = 0;
  static const int navMap = 1;
  static const int navProfile = 2;
  static const int navResources = 3;
}
