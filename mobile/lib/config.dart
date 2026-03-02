class AppConfig {
  const AppConfig({
    required this.environmentName,
    required this.apiBaseUrl,
    required this.appVersion,
    required this.buildNumber,
    required this.useFirebase,
    required this.googleServiceInfoPresent,
  });

  static const String _defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://maui-kokua-backend-1014781603190.us-central1.run.app',
  );

  static const String _defaultEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

  static const String _defaultAppVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  static const String _defaultBuildNumber = String.fromEnvironment(
    'APP_BUILD',
    defaultValue: '3',
  );

  static const bool _defaultUseFirebase = bool.fromEnvironment(
    'USE_FIREBASE',
    defaultValue: false,
  );

  static const bool _defaultGoogleServiceInfoPresent = bool.fromEnvironment(
    'GOOGLE_SERVICE_INFO_PRESENT',
    defaultValue: false,
  );

  static AppConfig _current = const AppConfig(
    environmentName: _defaultEnvironment,
    apiBaseUrl: _defaultApiBaseUrl,
    appVersion: _defaultAppVersion,
    buildNumber: _defaultBuildNumber,
    useFirebase: _defaultUseFirebase,
    googleServiceInfoPresent: _defaultGoogleServiceInfoPresent,
  );

  final String environmentName;
  final String apiBaseUrl;
  final String appVersion;
  final String buildNumber;
  final bool useFirebase;
  final bool googleServiceInfoPresent;

  static AppConfig get current => _current;

  static Future<AppConfig> load() async {
    final config = const AppConfig(
      environmentName: _defaultEnvironment,
      apiBaseUrl: _defaultApiBaseUrl,
      appVersion: _defaultAppVersion,
      buildNumber: _defaultBuildNumber,
      useFirebase: _defaultUseFirebase,
      googleServiceInfoPresent: _defaultGoogleServiceInfoPresent,
    );

    config.validate();
    _current = config;
    return config;
  }

  String get maskedApiBaseUrl {
    final uri = Uri.tryParse(apiBaseUrl.trim());
    if (uri == null || uri.host.isEmpty) {
      return 'invalid';
    }
    final scheme = uri.scheme.isEmpty ? 'https' : uri.scheme;
    return '$scheme://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}';
  }

  void validate() {
    final trimmed = apiBaseUrl.trim();

    if (trimmed.isEmpty) {
      throw const ConfigException('API base URL is missing.');
    }

    if (trimmed.contains('<') || trimmed.contains('>')) {
      throw const ConfigException(
        'API base URL still contains a placeholder value.',
      );
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ConfigException('API base URL is invalid: $trimmed');
    }

    if (useFirebase && !googleServiceInfoPresent) {
      throw const ConfigException(
        'Firebase is enabled but GoogleService-Info.plist was not declared as '
        'present. Ensure ios/Runner/GoogleService-Info.plist is bundled at '
        'build time or pass --dart-define=GOOGLE_SERVICE_INFO_PRESENT=true '
        'when your CI injects it.',
      );
    }
  }
}

class ConfigException implements Exception {
  const ConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}
