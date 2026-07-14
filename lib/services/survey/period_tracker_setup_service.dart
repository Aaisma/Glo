import '../../model/period_log_model.dart';
import '../../repo/period_repo_impl.dart';

class PeriodTrackerSetupService {
  static Future<void> initialize(String userId, DateTime lastCycleDate) async {
    final repo = PeriodRepoImpl();
    
    // Create an initial log for the last cycle date
    final log = PeriodLogModel(
      id: '', // Will be set by repo
      userId: userId,
      date: lastCycleDate,
      isPeriodDay: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await repo.addLog(log);
  }
}
