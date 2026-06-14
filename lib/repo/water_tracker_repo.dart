import '../model/water_tracker_model.dart';

abstract class WaterTrackerRepo {
  Future<void> saveWater(WaterTrackerModel model);
  Future<WaterTrackerModel?> getWater();
}
