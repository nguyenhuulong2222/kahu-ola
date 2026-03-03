import 'dart:developer' as developer;

import '../diagnostics/diagnostics_store.dart';

class AppLogger {
  AppLogger._();

  static void debug(String msg, {Map<String, dynamic>? meta}) {
    assert(() {
      _emit('DEBUG', msg, meta);
      return true;
    }());
  }

  static void info(String msg, {Map<String, dynamic>? meta}) {
    assert(() {
      _emit('INFO', msg, meta);
      return true;
    }());
  }

  static void warn(String msg, {Map<String, dynamic>? meta}) {
    _emit('WARN', msg, meta);
  }

  static void error(
    String msg, {
    Map<String, dynamic>? meta,
    Object? err,
    StackTrace? stack,
  }) {
    _emit('ERROR', msg, meta);
    if (err != null) {
      DiagnosticsStore.instance.recordError(
        err,
        stack,
        domain: FailureDomain.runtime,
      );
    }
  }

  static void fatal(String msg, {Object? err, StackTrace? stack}) {
    _emit('FATAL', msg, null);
    if (err != null) {
      DiagnosticsStore.instance.recordError(
        err,
        stack,
        domain: FailureDomain.runtime,
      );
    }
  }

  static void _emit(String level, String msg, Map<String, dynamic>? meta) {
    final payload = <String, Object?>{
      'level': level,
      'message': msg,
      if (meta != null) ..._sanitize(meta),
    };
    developer.log(payload.toString(), name: 'KahuOla');
  }

  static Map<String, Object?> _sanitize(Map<String, dynamic> meta) {
    final sanitized = <String, Object?>{};
    for (final entry in meta.entries) {
      final key = entry.key.toLowerCase();
      if (key.contains('token') ||
          key.contains('header') ||
          key.contains('email') ||
          key.contains('device')) {
        continue;
      }
      sanitized[entry.key] = entry.value;
    }
    return sanitized;
  }
}
