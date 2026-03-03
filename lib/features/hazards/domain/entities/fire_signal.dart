import '../enums/freshness.dart';
import '../enums/severity_level.dart';

class FireSignal {
  const FireSignal({
    required this.id,
    required this.provider,
    required this.eventTime,
    required this.severity,
    required this.freshness,
    required this.reasonCodes,
    required this.headline,
  });

  final String id;
  final String provider;
  final DateTime eventTime;
  final SeverityLevel severity;
  final Freshness freshness;
  final List<String> reasonCodes;
  final String headline;
}
