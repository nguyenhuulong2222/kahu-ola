import 'package:flutter/foundation.dart';

import '../../features/hazards/domain/enums/aggregator_health.dart';

enum FailureDomain { network, parse, firebase, runtime }

enum RemoteConfigStatus { notFetched, loaded, fallback, unavailable }

enum HazardEndpoint { fire, smoke, perimeter }

class DiagnosticsStore extends ChangeNotifier {
  DiagnosticsStore._();

  static final DiagnosticsStore instance = DiagnosticsStore._();

  bool firebaseReady = false;
  String? firebaseError;

  RemoteConfigStatus remoteConfigStatus = RemoteConfigStatus.notFetched;
  String activeBaseUrl = '';

  bool isOffline = false;

  AggregatorHealth aggregatorHealth = AggregatorHealth.healthy;
  int consecutiveFailures = 0;
  static const int degradedThreshold = 3;

  bool inRateLimitCooldown = false;
  DateTime? rateLimitCooldownUntil;

  DateTime? lastFireFetchAt;
  DateTime? lastSmokeFetchAt;
  DateTime? lastPerimeterFetchAt;

  String? lastFireError;
  String? lastSmokeError;
  String? lastPerimeterError;

  int networkFailures = 0;
  int parseFailures = 0;
  int crashCount = 0;

  void recordError(
    Object error,
    StackTrace? stack, {
    required FailureDomain domain,
  }) {
    switch (domain) {
      case FailureDomain.network:
        networkFailures++;
        consecutiveFailures++;
        _refreshHealth();
        break;
      case FailureDomain.parse:
        parseFailures++;
        consecutiveFailures++;
        _refreshHealth();
        break;
      case FailureDomain.firebase:
        firebaseError = error.toString();
        break;
      case FailureDomain.runtime:
        crashCount++;
        break;
    }
    notifyListeners();
  }

  void recordEndpointError(
    HazardEndpoint endpoint,
    Object error, {
    required FailureDomain domain,
    StackTrace? stack,
  }) {
    final message = error.toString();
    switch (endpoint) {
      case HazardEndpoint.fire:
        lastFireError = message;
        break;
      case HazardEndpoint.smoke:
        lastSmokeError = message;
        break;
      case HazardEndpoint.perimeter:
        lastPerimeterError = message;
        break;
    }
    recordError(error, stack, domain: domain);
  }

  void recordFetchSuccess(HazardEndpoint endpoint) {
    final now = DateTime.now().toUtc();
    consecutiveFailures = 0;
    aggregatorHealth = AggregatorHealth.healthy;
    inRateLimitCooldown = false;
    rateLimitCooldownUntil = null;

    switch (endpoint) {
      case HazardEndpoint.fire:
        lastFireFetchAt = now;
        lastFireError = null;
        break;
      case HazardEndpoint.smoke:
        lastSmokeFetchAt = now;
        lastSmokeError = null;
        break;
      case HazardEndpoint.perimeter:
        lastPerimeterFetchAt = now;
        lastPerimeterError = null;
        break;
    }

    notifyListeners();
  }

  void markOffline(bool value) {
    if (isOffline == value) {
      return;
    }
    isOffline = value;
    notifyListeners();
  }

  void enterRateLimitCooldown({int seconds = 60}) {
    final now = DateTime.now().toUtc();
    final cappedSeconds = seconds.clamp(60, 300);
    inRateLimitCooldown = true;
    rateLimitCooldownUntil = now.add(Duration(seconds: cappedSeconds));
    notifyListeners();
  }

  bool get isCooldownActive {
    final until = rateLimitCooldownUntil;
    return inRateLimitCooldown &&
        until != null &&
        DateTime.now().toUtc().isBefore(until);
  }

  void setFirebaseStatus({required bool ready, String? error}) {
    firebaseReady = ready;
    firebaseError = error;
    if (!ready && error != null) {
      recordError(error, null, domain: FailureDomain.firebase);
      return;
    }
    notifyListeners();
  }

  void markAggregatorUnavailable() {
    aggregatorHealth = AggregatorHealth.unavailable;
    notifyListeners();
  }

  void reset() {
    networkFailures = 0;
    parseFailures = 0;
    crashCount = 0;
    consecutiveFailures = 0;
    lastFireError = null;
    lastSmokeError = null;
    lastPerimeterError = null;
    inRateLimitCooldown = false;
    rateLimitCooldownUntil = null;
    aggregatorHealth = AggregatorHealth.healthy;
    notifyListeners();
  }

  void _refreshHealth() {
    if (consecutiveFailures >= degradedThreshold) {
      aggregatorHealth = AggregatorHealth.degraded;
    }
  }
}
