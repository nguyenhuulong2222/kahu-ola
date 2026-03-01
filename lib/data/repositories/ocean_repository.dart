import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../models/ocean_model.dart';

/// Ocean Safety repository contract (A5)
/// Sources: PacIOOS (currents/tides) + ALOHA (deep-sea pressure) + USGS (flood)
abstract class OceanRepository {
  /// Offshore currents and tidal data (PacIOOS)
  Future<Either<Failure, List<OceanModel>>> getOceanConditions();

  /// Deep-sea pressure readings for tsunami detection (ALOHA)
  Future<Either<Failure, List<DeepSeaPressureModel>>> getDeepSeaPressure();

  /// Flash flood warnings from USGS stream gauges
  Future<Either<Failure, Map<String, dynamic>>> getFloodWarnings();

  /// Harbor inundation levels (PacIOOS coast)
  Future<Either<Failure, Map<String, dynamic>>> getHarborInundation();

  /// Cached fallback for ocean conditions
  Future<Either<Failure, List<OceanModel>>> getCachedOceanConditions();
}
