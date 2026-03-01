import 'package:equatable/equatable.dart';

/// Base failure class — Graceful Degradation pattern
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// ── Network failures ─────────────────────────────────────────────────────────

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.', super.code});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Request timed out. Showing cached data.', super.code});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Used when a government API is down — show stale data badge
class StaleDataFailure extends Failure {
  final DateTime? lastUpdated;

  const StaleDataFailure({
    super.message = 'API unavailable. Displaying last known data.',
    super.code,
    this.lastUpdated,
  });

  @override
  List<Object?> get props => [...super.props, lastUpdated];
}

// ── Local failures ────────────────────────────────────────────────────────────

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache read error.', super.code});
}

class ParseFailure extends Failure {
  const ParseFailure({super.message = 'Failed to parse API response.', super.code});
}

// ── Permission failures ───────────────────────────────────────────────────────

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure({
    super.message = 'Location permission denied. Risk calculation requires device-side location.',
    super.code,
  });
}
