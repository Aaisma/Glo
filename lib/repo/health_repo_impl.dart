import '../model/health_model.dart';
import '../services/health_service.dart';
import 'health_repo.dart';

class HealthRepoImpl implements HealthRepo {
  final HealthService _service = HealthService();

  @override
  Future<void> addHealthItem(HealthModel item, String userId) {
    return _service.addHealthItem(item, userId);
  }

  @override
  Future<List<HealthModel>> getHealthItems(String userId) {
    return _service.getHealthItems(userId);
  }

  @override
  Future<void> updateHealthItem(HealthModel item) {
    return _service.updateHealthItem(item);
  }

  @override
  Future<void> deleteHealthItem(String id) {
    return _service.deleteHealthItem(id);
  }
}
