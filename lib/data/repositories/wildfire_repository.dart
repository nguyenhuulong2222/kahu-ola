import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../models/wildfire_model.dart';

/// Wildfire & Air Quality repository contract (A3)
/// Sources: NASA FIRMS (fire hotspots) + AirNow (AQI/Vog) + MesoWest (wind)
abstract class WildfireRepository {
  /// Active fire hotspots for Hawaii (NASA FIRMS)
  Future<Either<Failure, List<WildfireModel>>> getFireHotspots();

  /// Current air quality index (AirNow)
  Future<Either<Failure, List<AirQualityModel>>> getAirQuality();

  /// Haleakalā summit wind gusts (MesoWest / RAWS)
  Future<Either<Failure, Map<String, dynamic>>> getSummitWindData();

  /// Cached fallback for all wildfire data
  Future<Either<Failure, List<WildfireModel>>> getCachedFireHotspots();
}
