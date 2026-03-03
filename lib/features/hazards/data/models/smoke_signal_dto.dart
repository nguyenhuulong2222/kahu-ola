import '../../../../core/network/api_exceptions.dart';
import '../../domain/entities/smoke_signal.dart';
import '../../domain/enums/freshness.dart';
import '../../domain/enums/severity_level.dart';

class SmokeSignalDto {
  const SmokeSignalDto({required this.generatedAt, required this.signals});

  final DateTime generatedAt;
  final List<SmokeSignal> signals;

  factory SmokeSignalDto.fromJson(Map<String, dynamic> json) {
    final generatedAt = _parseGeneratedAt(json);
    final rawSignals = _parseSignals(json);

    return SmokeSignalDto(
      generatedAt: generatedAt,
      signals: rawSignals.map((dynamic signal) {
        return _parseSignal(signal as Map<String, dynamic>, generatedAt);
      }).toList(),
    );
  }

  static SmokeSignal _parseSignal(
    Map<String, dynamic> signal,
    DateTime generatedAt,
  ) {
    if (_readString(signal, 'type') != 'SmokeSignal') {
      throw const ParseException('Invalid signal type for smoke endpoint');
    }

    final source = _readMap(signal, 'source');
    final severity = _readMap(signal, 'severity');
    final properties = _readOptionalMap(signal, 'properties');
    final eventTime = DateTime.parse(_readString(signal, 'event_time'));
    final ttlSeconds = _readInt(signal, 'ttl_seconds');

    final aqiValue = properties['aqi'];
    final aqi = aqiValue is num ? aqiValue.toInt() : 0;

    return SmokeSignal(
      id: _readString(signal, 'id'),
      provider: _readString(source, 'provider'),
      eventTime: eventTime.toUtc(),
      severity: severityLevelFromWire(_readString(severity, 'level')),
      freshness: freshnessFrom(
        generatedAt: generatedAt,
        eventTime: eventTime,
        ttlSeconds: ttlSeconds,
      ),
      aqi: aqi,
      headline: properties['headline'] is String
          ? properties['headline'] as String
          : 'Smoke advisory active',
      advisory: properties['advisory'] is String
          ? properties['advisory'] as String
          : 'Sensitive groups should reduce outdoor exposure.',
    );
  }

  static DateTime _parseGeneratedAt(Map<String, dynamic> json) {
    final rawValue = json['generated_at'];
    if (rawValue is! String || rawValue.isEmpty) {
      throw const ParseException('generated_at field missing');
    }
    return DateTime.parse(rawValue).toUtc();
  }

  static List<dynamic> _parseSignals(Map<String, dynamic> json) {
    final rawSignals = json['signals'];
    if (rawSignals is! List<dynamic>) {
      throw const ParseException('signals field missing');
    }
    return rawSignals;
  }

  static Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    throw ParseException('$key field missing');
  }

  static Map<String, dynamic> _readOptionalMap(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value == null) {
      return <String, dynamic>{};
    }
    return _readMap(json, key);
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw ParseException('$key field missing');
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw ParseException('$key field missing');
  }
}
