import '../model/water_tracker_model.dart';

class WaterTrackerViewModel {
  double currentIntake = 1.2;
  double goal = 2.5;

  WaterTrackerModel get model {
    return WaterTrackerModel(
      currentIntake: currentIntake,
      goal: goal,
    );
  }

  void addWater(double amount) {
    currentIntake += amount;

    if (currentIntake > goal) {
      currentIntake = goal;
    }
  }
}