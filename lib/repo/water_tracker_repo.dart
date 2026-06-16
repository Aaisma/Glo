import '../model/water_tracker_model.dart';

abstract class WaterTrackerRepo {
  Future<WaterTrackerModel?> getData();
  Future<void> saveData(WaterTrackerModel model);
}