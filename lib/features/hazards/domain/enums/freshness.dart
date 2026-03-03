enum Freshness { unknown, fresh, staleOk, staleDrop }

Freshness freshnessFrom({
  required DateTime generatedAt,
  required DateTime eventTime,
  required int ttlSeconds,
}) {
  final elapsedSeconds = generatedAt
      .toUtc()
      .difference(eventTime.toUtc())
      .inSeconds;

  if (elapsedSeconds < 0) {
    return Freshness.unknown;
  }
  if (elapsedSeconds <= ttlSeconds) {
    return Freshness.fresh;
  }
  if (elapsedSeconds <= ttlSeconds * 2) {
    return Freshness.staleOk;
  }
  return Freshness.staleDrop;
}

extension FreshnessLabel on Freshness {
  String get label {
    switch (this) {
      case Freshness.unknown:
        return 'Unknown';
      case Freshness.fresh:
        return 'Fresh';
      case Freshness.staleOk:
        return 'Stale';
      case Freshness.staleDrop:
        return 'Expired';
    }
  }
}
