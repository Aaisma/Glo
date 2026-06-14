import '../model/water_history_model.dart';
import '../repo/water_history_repo.dart';

class WaterHistoryViewModel {
  final WaterHistoryRepo repo;

  WaterHistoryViewModel(this.repo);

  List<WaterHistoryModel> history = [];

  Future<void> loadHistory() async {
    history = await repo.getHistory();
  }

  Future<void> saveToday(WaterHistoryModel model) async {
    await repo.saveToday(model);
    await loadHistory();
  }
}