import '../entities/fire_signal.dart';
import '../repositories/hazards_repository.dart';

class GetFireSignals {
  const GetFireSignals(this._repository);

  final HazardsRepository _repository;

  Future<List<FireSignal>> call() {
    return _repository.getFireSignals();
  }
}
