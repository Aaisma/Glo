import '../model/water_history_model.dart';
import '../repo/water_history_repo_impl.dart';

class WaterHistoryViewModel {
  final WaterHistoryRepoImpl repo;

  List<WaterHistoryModel> history = [];

  WaterHistoryViewModel(this.repo);

  Future<void> load(String userId) async {
    history = await repo.getHistory(userId);
  }

  Future<void> saveToday(
      String userId,
      double intake,
      double goal,
      ) async {
    final today = DateTime.now().toIso8601String().split("T")[0];

    await repo.saveDaily(
      userId,
      WaterHistoryModel(
        date: today,
        intake: intake,
        goal: goal,
      ),
    );
  }
}