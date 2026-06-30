import 'package:flutter/material.dart';
import '../model/water_tracker_model.dart';
import '../repo/water_tracker_repo.dart';

class WaterTrackerViewModel extends ChangeNotifier {
  final WaterTrackerRepo _repo;

  WaterTrackerViewModel(this._repo);

  bool isLoading = false;
  String? errorMessage;

  double intake = 0;
  double goal = 3.0;

  TimeOfDay? reminderTime;

  // tracks which thresholds we've already shown motivation for today,
  // so the same message doesn't repeat every time intake updates
  final Set<int> _celebratedThresholds = {};
  String? motivationMessage;

  String _todayDate() => DateTime.now().toIso8601String().split("T")[0];

  Future<void> loadToday(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final entry = await _repo.getEntry(userId, _todayDate());
      if (entry != null) {
        intake = entry.intake;
        goal = entry.goal;
      }
    } catch (e) {
      errorMessage = "Failed to load today's data: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double get progress => goal <= 0 ? 0 : (intake / goal).clamp(0.0, 1.0);
  double get percent => progress * 100;
  double get remaining => (goal - intake) < 0 ? 0 : (goal - intake);

  void addIntake(double amount) {
    intake += amount;
    if (intake < 0) intake = 0;
    _checkMotivation();
    notifyListeners();
  }

  void subtractIntake(double amount) {
    intake -= amount;
    if (intake < 0) intake = 0;
    notifyListeners();
  }

  void setCustomIntake(double value) {
    intake = value < 0 ? 0 : value;
    _checkMotivation();
    notifyListeners();
  }

  void setGoal(double newGoal) {
    goal = newGoal <= 0 ? 0.5 : newGoal;
    _celebratedThresholds.clear();
    notifyListeners();
  }

  void setReminderTime(TimeOfDay time) {
    reminderTime = time;
    notifyListeners();
  }

  void _checkMotivation() {
    final pct = percent;
    final thresholds = [25, 50, 75, 100];
    for (final t in thresholds) {
      if (pct >= t && !_celebratedThresholds.contains(t)) {
        _celebratedThresholds.add(t);
        if (t == 100) {
          motivationMessage = "🎉 Goal reached! Amazing hydration today!";
        } else {
          motivationMessage = "Great job! You're $t% of the way to your goal 💧";
        }
      }
    }
  }

  void clearMotivationMessage() {
    motivationMessage = null;
  }

  Future<void> saveToday(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final entry = WaterTrackerModel(
        userId: userId,
        date: _todayDate(),
        intake: intake,
        goal: goal,
      );
      await _repo.saveEntry(entry);
    } catch (e) {
      errorMessage = "Failed to save: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}