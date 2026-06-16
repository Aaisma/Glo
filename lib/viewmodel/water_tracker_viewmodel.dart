import '../model/water_tracker_model.dart';
import '../repo/water_tracker_repo_impl.dart';

class WaterTrackerViewModel {
  final WaterTrackerRepoImpl repo;

  double currentIntake = 0;
  double goal = 2.5;

  WaterTrackerViewModel(this.repo);

  Future<void> load(String userId) async {
    final data = await repo.getData(userId);

    if (data != null) {
      currentIntake = data.intake;
      goal = data.goal;
    }
  }

  Future<void> addWater(double amount, String userId) async {
    currentIntake += amount;

    await repo.saveData(
      WaterTrackerModel(
        userId: userId,
        intake: currentIntake,
        goal: goal,
        date: DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<void> setGoal(double newGoal, String userId) async {
    goal = newGoal;

    await repo.saveData(
      WaterTrackerModel(
        userId: userId,
        intake: currentIntake,
        goal: goal,
        date: DateTime.now().toIso8601String(),
      ),
    );
  }
}