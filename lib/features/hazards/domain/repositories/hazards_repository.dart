import '../entities/fire_signal.dart';
import '../entities/perimeter.dart';
import '../entities/smoke_signal.dart';

abstract class HazardsRepository {
  Future<List<FireSignal>> getFireSignals();

  Future<List<SmokeSignal>> getSmokeSignals();

  Future<List<Perimeter>> getPerimeters();
}
