import '../../../../core/network/api_exceptions.dart';
import '../../domain/entities/fire_signal.dart';
import '../../domain/enums/freshness.dart';
import '../../domain/enums/severity_level.dart';

class FireSignalDto {
  const FireSignalDto({required this.generatedAt, required this.signals});

  final DateTime generatedAt;
  final List<FireSignal> signals;

  factory FireSignalDto.fromJson(Map<String, dynamic> json) {
    final generatedAt = _parseGeneratedAt(json);
    final rawSignals = _parseSignals(json);

    return FireSignalDto(
      generatedAt: generatedAt,
      signals: rawSignals.map((dynamic signal) {
        return _parseSignal(signal as Map<String, dynamic>, generatedAt);
      }).toList(),
    );
  }

  static FireSignal _parseSignal(
    Map<String, dynamic> signal,
    DateTime generatedAt,
  ) {
    if (_readString(signal, 'type') != 'FireSignal') {
      throw const ParseException('Invalid signal type for fire endpoint');
    }

    final source = _readMap(signal, 'source');
    final severity = _readMap(signal, 'severity');
    final properties = _readOptionalMap(signal, 'properties');
    final eventTime = DateTime.parse(_readString(signal, 'event_time'));
    final ttlSeconds = _readInt(signal, 'ttl_seconds');
    final reasonCodes = _readStringList(severity['reason_codes']);

    return FireSignal(
      id: _readString(signal, 'id'),
      provider: _readString(source, 'provider'),
      eventTime: eventTime.toUtc(),
      severity: severityLevelFromWire(_readString(severity, 'level')),
      freshness: freshnessFrom(
        generatedAt: generatedAt,
        eventTime: eventTime,
        ttlSeconds: ttlSeconds,
      ),
      reasonCodes: reasonCodes,
      headline: properties['headline'] is String
          ? properties['headline'] as String
          : 'Wildfire hotspot detected',
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

  static List<String> _readStringList(Object? rawValue) {
    if (rawValue == null) {
      return const <String>[];
    }
    if (rawValue is! List) {
      throw const ParseException('reason_codes field invalid');
    }
    return rawValue.map((dynamic item) {
      if (item is! String) {
        throw const ParseException('reason_codes field invalid');
      }
      return item;
    }).toList();
  }
}
