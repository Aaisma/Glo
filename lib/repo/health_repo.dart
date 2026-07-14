import '../model/health_model.dart';

abstract class HealthRepo {
  Future<void> addHealthItem(
      HealthModel item,
      String userId,
      );

  Future<void> updateHealthItem(
      HealthModel item,
      String userId,
      );

  Future<void> deleteHealthItem(String id);

  Future<List<HealthModel>> getHealthItems(
      String userId,
      );

  Stream<List<HealthModel>> getHealthItemsStream(
      String userId,
      );

  Stream<int> getHealthItemCountStream(
      String userId,
      );

  Stream<int> getAllHealthItemCountStream();
}