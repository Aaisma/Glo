import '../model/acne_tracker_model.dart';

abstract class AcneRepo {
  Future<void> saveEntry(AcneTrackerModel model);
  Future<AcneTrackerModel?> getEntry(String userId, String date);
  Future<List<AcneTrackerModel>> getAllEntries(String userId);
  Future<void> deleteEntry(String userId, String date);
}