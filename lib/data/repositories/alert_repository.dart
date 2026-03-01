import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../models/alert_model.dart';

/// Alert Buddy repository contract (A1)
/// Fetches NWS alerts with Graceful Degradation fallback.
abstract class AlertRepository {
  /// Returns current NWS alerts for Hawaii or a [Failure]
  Future<Either<Failure, List<AlertModel>>> getActiveAlerts();

  /// Returns cached/stale alerts when API is unavailable
  Future<Either<Failure, List<AlertModel>>> getCachedAlerts();
}
