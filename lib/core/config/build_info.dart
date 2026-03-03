class BuildInfo {
  BuildInfo._();

  static const String version = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0+10',
  );

  static const String appVersion = version;

  static const String buildName = String.fromEnvironment(
    'APP_BUILD_NAME',
    defaultValue: '1.0.0',
  );

  static const String buildNumber = String.fromEnvironment(
    'APP_BUILD_NUMBER',
    defaultValue: '10',
  );
}
