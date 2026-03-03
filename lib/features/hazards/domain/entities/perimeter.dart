import '../enums/freshness.dart';

class Perimeter {
  const Perimeter({
    required this.id,
    required this.provider,
    required this.eventTime,
    required this.freshness,
    required this.official,
    required this.headline,
    required this.acres,
  });

  final String id;
  final String provider;
  final DateTime eventTime;
  final Freshness freshness;
  final bool official;
  final String headline;
  final double acres;
}
