import '../enums/freshness.dart';
import '../enums/severity_level.dart';

class SmokeSignal {
  const SmokeSignal({
    required this.id,
    required this.provider,
    required this.eventTime,
    required this.severity,
    required this.freshness,
    required this.aqi,
    required this.headline,
    required this.advisory,
  });

  final String id;
  final String provider;
  final DateTime eventTime;
  final SeverityLevel severity;
  final Freshness freshness;
  final int aqi;
  final String headline;
  final String advisory;
}
