import '../model/water_tracker_model.dart';
import '../model/water_history_model.dart';
import '../repo/water_tracker_repo_impl.dart';

class WaterTrackerViewModel {
  final WaterTrackerRepoImpl repo;

  double currentIntake = 0;
  double goal = 2.5;
  String noteText = "";

  WaterTrackerViewModel(this.repo);

  // Load latest saved data
  Future<void> load(String userId) async {
    final data = await repo.getData(userId);

    if (data != null) {
      currentIntake = data.intake;
      goal = data.goal;
      noteText = data.note;
    }
  }

  // Add water intake
  Future<void> addWater(double amount, String userId) async {
    currentIntake += amount;

    if (currentIntake > goal) {
      currentIntake = goal;
    }

    await repo.saveData(
      WaterTrackerModel(
        userId: userId,
        intake: currentIntake,
        goal: goal,
        date: DateTime.now().toString(),
        note: noteText,
      ),
    );

    await _saveHistory(userId);
  }

  // Set daily goal
  Future<void> setGoal(double newGoal, String userId) async {
    goal = newGoal;

    await repo.saveData(
      WaterTrackerModel(
        userId: userId,
        intake: currentIntake,
        goal: goal,
        date: DateTime.now().toString(),
        note: noteText,
      ),
    );

    await _saveHistory(userId);
  }

  // Update note
  Future<void> updateNote(String newNote, String userId) async {
    noteText = newNote;

    await repo.saveData(
      WaterTrackerModel(
        userId: userId,
        intake: currentIntake,
        goal: goal,
        date: DateTime.now().toString(),
        note: noteText,
      ),
    );

    await _saveHistory(userId);
  }

  // SAVE HISTORY (internal helper)
  Future<void> _saveHistory(String userId) async {
    await repo.saveHistory(
      userId,
      WaterHistoryModel(
        date: DateTime.now().toIso8601String().split("T")[0],
        intake: currentIntake,
        goal: goal,
        note: noteText,
      ),
    );
  }
}