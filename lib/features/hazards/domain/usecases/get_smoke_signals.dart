import '../entities/smoke_signal.dart';
import '../repositories/hazards_repository.dart';

class GetSmokeSignals {
  const GetSmokeSignals(this._repository);

  final HazardsRepository _repository;

  Future<List<SmokeSignal>> call() {
    return _repository.getSmokeSignals();
  }
}
