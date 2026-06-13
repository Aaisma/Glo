import 'water_tracker_repo.dart';

class WaterTrackerRepoImpl implements WaterTrackerRepo {
  double storedValue = 0.0;

  @override
  void saveWater(double value) {
    storedValue = value;
  }
}