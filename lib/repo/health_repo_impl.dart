import '../model/health_model.dart';
import '../services/health_service.dart';
import 'health_repo.dart';

class HealthRepoImpl implements HealthRepo {
  final HealthService _service;

  HealthRepoImpl({
    HealthService? service,
  }) : _service = service ?? HealthService();

  @override
  Future<void> addHealthItem(
      HealthModel item,
      String userId,
      ) {
    return _service.addHealthItem(item, userId);
  }

  @override
  Future<void> updateHealthItem(
      HealthModel item,
      String userId,
      ) {
    return _service.updateHealthItem(item, userId);
  }

  @override
  Future<void> deleteHealthItem(String id) {
    return _service.deleteHealthItem(id);
  }

  @override
  Future<List<HealthModel>> getHealthItems(
      String userId,
      ) {
    return _service.getHealthItems(userId);
  }

  @override
  Stream<List<HealthModel>> getHealthItemsStream(
      String userId,
      ) {
    return _service.getHealthItemsStream(userId);
  }

  @override
  Stream<int> getHealthItemCountStream(
      String userId,
      ) {
    return _service.getHealthItemCountStream(userId);
  }

  @override
  Stream<int> getAllHealthItemCountStream() {
    return _service.getAllHealthItemCountStream();
  }
}