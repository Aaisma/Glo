import '../model/water_tracker_model.dart';
import '../repo/water_tracker_repo.dart';

class WaterTrackerViewModel {
  final WaterTrackerRepo repo;

  WaterTrackerViewModel(this.repo);

  double currentIntake = 1.2;
  double goal = 2.5;

  Future<void> loadData() async {
    final data = await repo.getWater();

    if (data != null) {
      currentIntake = data.currentIntake;
      goal = data.goal;
    }
  }

  Future<void> addWater(double amount) async {
    currentIntake += amount;

    if (currentIntake > goal) {
      currentIntake = goal;
    }

    await repo.saveWater(
      WaterTrackerModel(
        currentIntake: currentIntake,
        goal: goal,
      ),
    );
  }
}