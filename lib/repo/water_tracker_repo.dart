import '../model/water_tracker_model.dart';

abstract class WaterTrackerRepo {
  Future<void> saveEntry(WaterTrackerModel model);
  Future<WaterTrackerModel?> getEntry(String userId, String date);
}