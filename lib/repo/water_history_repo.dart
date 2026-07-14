import '../model/water_history_model.dart';

abstract class WaterHistoryRepo {
  Future<void> saveToday(WaterHistoryModel model);
  Future<List<WaterHistoryModel>> getHistory();
}