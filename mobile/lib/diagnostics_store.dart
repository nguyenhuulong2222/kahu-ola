import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'config.dart';

enum NetworkReachability {
  unknown,
  reachable,
  unreachable,
}

class DiagnosticsStore extends ChangeNotifier {
  DiagnosticsStore._();

  static final DiagnosticsStore instance = DiagnosticsStore._();

  static const int _maxLogLines = 200;

  final ListQueue<String> _logLines = ListQueue<String>();

  AppConfig? _config;
  String _lastBootstrapStep = 'Not started';
  String? _lastError;
  String? _lastStackTrace;
  NetworkReachability _networkReachability = NetworkReachability.unknown;

  AppConfig? get config => _config;
  String get lastBootstrapStep => _lastBootstrapStep;
  String? get lastError => _lastError;
  String? get lastStackTrace => _lastStackTrace;
  NetworkReachability get networkReachability => _networkReachability;
  List<String> get logLines => List<String>.unmodifiable(_logLines);

  String get networkReachabilityLabel {
    switch (_networkReachability) {
      case NetworkReachability.reachable:
        return 'Reachable';
      case NetworkReachability.unreachable:
        return 'Unreachable';
      case NetworkReachability.unknown:
        return 'Unknown';
    }
  }

  void attachConfig(AppConfig config) {
    _config = config;
    log(
      'CONFIG: env=${config.environmentName}, baseUrl=${config.maskedApiBaseUrl}, '
      'firebase=${config.useFirebase ? "enabled" : "disabled"}',
    );
    notifyListeners();
  }

  void setBootstrapStep(String step) {
    _lastBootstrapStep = step;
    log(step);
    notifyListeners();
  }

  void setNetworkReachability(NetworkReachability value, {String? reason}) {
    _networkReachability = value;
    if (reason != null && reason.isNotEmpty) {
      log('NETWORK: ${value.name} ($reason)');
    } else {
      log('NETWORK: ${value.name}');
    }
    notifyListeners();
  }

  void log(String message) {
    final line = '[${DateTime.now().toIso8601String()}] $message';
    debugPrint(line);
    _logLines.addLast(line);
    while (_logLines.length > _maxLogLines) {
      _logLines.removeFirst();
    }
    notifyListeners();
  }

  void recordFlutterError(FlutterErrorDetails details) {
    FlutterError.presentError(details);
    recordError(
      details.exception,
      details.stack ?? StackTrace.current,
      source: 'flutter_framework',
    );
  }

  void recordError(
    Object error,
    StackTrace stackTrace, {
    required String source,
  }) {
    _lastError = '$source: $error';
    _lastStackTrace = stackTrace.toString();
    log('ERROR [$source]: $error');
    notifyListeners();
  }

  void clearEphemeralState() {
    _lastError = null;
    _lastStackTrace = null;
    _networkReachability = NetworkReachability.unknown;
    _lastBootstrapStep = 'Reset by user';
    log('DIAGNOSTICS: ephemeral state reset');
    notifyListeners();
  }

  void beginBootstrapCycle() {
    _lastError = null;
    _lastStackTrace = null;
    _networkReachability = NetworkReachability.unknown;
    notifyListeners();
  }

  String buildDiagnosticsReport() {
    final buffer = StringBuffer()
      ..writeln('Kahu Ola Diagnostics')
      ..writeln('Environment: ${_config?.environmentName ?? "unknown"}')
      ..writeln('Version: ${_config?.appVersion ?? "unknown"}')
      ..writeln('Build: ${_config?.buildNumber ?? "unknown"}')
      ..writeln('API Base URL: ${_config?.maskedApiBaseUrl ?? "unknown"}')
      ..writeln('Last bootstrap step: $_lastBootstrapStep')
      ..writeln('Network reachability: $networkReachabilityLabel')
      ..writeln('Last error: ${_lastError ?? "none"}')
      ..writeln('Stack trace:')
      ..writeln(_lastStackTrace ?? 'none')
      ..writeln('Recent logs:');

    for (final line in _logLines) {
      buffer.writeln(line);
    }

    return buffer.toString();
  }
}
