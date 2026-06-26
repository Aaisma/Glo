import '../model/health_model.dart';

abstract class HealthRepo {
  Future<void> addHealthItem(HealthModel item, String userId);
  Future<List<HealthModel>> getHealthItems(String userId);
  Future<void> updateHealthItem(HealthModel item);
  Future<void> deleteHealthItem(String id);
}
