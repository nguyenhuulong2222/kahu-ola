import '../entities/perimeter.dart';
import '../repositories/hazards_repository.dart';

class GetPerimeters {
  const GetPerimeters(this._repository);

  final HazardsRepository _repository;

  Future<List<Perimeter>> call() {
    return _repository.getPerimeters();
  }
}
