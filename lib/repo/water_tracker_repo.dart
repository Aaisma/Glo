import '../model/water_tracker_model.dart';

abstract class WaterTrackerRepo {
  Future<void> addIntake(String userId, WaterIntake intake);
  Future<List<WaterIntake>> getIntakes(String userId);
  Future<void> deleteIntake(String userId, String intakeId);
}
