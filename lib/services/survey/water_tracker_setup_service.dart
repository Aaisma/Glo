import 'package:intl/intl.dart';
import '../../model/water_tracker_model.dart';
import '../../repo/water_tracker_repo_impl.dart';

class WaterTrackerSetupService {
  static Future<void> initialize(String userId, double waterGoal) async {
    final repo = WaterTrackerRepoImpl();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final model = WaterTrackerModel(
      userId: userId,
      date: today,
      intake: 0.0,
      goal: waterGoal,
    );

    await repo.saveEntry(model);
  }
}
