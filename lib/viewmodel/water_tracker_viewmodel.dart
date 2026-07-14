import 'package:flutter/material.dart';
import '../model/water_tracker_model.dart';
import '../repo/water_tracker_repo.dart';

class WaterTrackerViewModel extends ChangeNotifier {
  final WaterTrackerRepo _repo;
  String? _userId;

  WaterTrackerViewModel(this._repo);

  void updateUserId(String? newUserId) {
    if (_userId != newUserId) {
      _userId = newUserId;
      if (_userId != null) {
        loadToday(_userId!);
      } else {
        intake = 0;
        history = [];
        notifyListeners();
      }
    }
  }

  String? get userId => _userId;

  bool isLoading = false;
  String? errorMessage;

  double intake = 0;
  double goal = 3.0;
  String note = "";
  TimeOfDay? reminderTime;

  List<WaterTrackerModel> history = [];
  double lastAddedAmount = 0.0;

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
        note = entry.note;
      } else {
        intake = 0;
        final hist = await _repo.getHistory(userId);
        if (hist.isNotEmpty) {
          goal = hist.first.goal;
        } else {
          goal = 2.5;
        }
        note = "";
      }
      history = await _repo.getHistory(userId);
    } catch (e) {
      errorMessage = "Failed to load: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addIntake(double amount) {
    intake += amount;
    if (intake < 0) intake = 0;
    lastAddedAmount = amount;
    notifyListeners();
  }

  void subtractIntake(double amount) {
    intake -= amount;
    if (intake < 0) intake = 0;
    lastAddedAmount = 0.0;
    notifyListeners();
  }

  void undoLastIntake() {
    if (lastAddedAmount > 0) {
      intake -= lastAddedAmount;
      if (intake < 0) intake = 0;
      lastAddedAmount = 0.0;
      notifyListeners();
    }
  }

  void setGoal(double newGoal) {
    goal = newGoal <= 0 ? 0.5 : newGoal;
    notifyListeners();
  }

  void setReminderTime(TimeOfDay time) {
    reminderTime = time;
    notifyListeners();
  }

  void updateNote(String value) {
    note = value;
    notifyListeners();
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
        note: note,
      );
      await _repo.saveEntry(entry);
      history = await _repo.getHistory(userId);
    } catch (e) {
      errorMessage = "Failed to save: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  int get streak {
    if (history.isEmpty) return 0;

    final Map<String, WaterTrackerModel> uniqueEntries = {};
    for (final entry in history) {
      if (entry.date.isNotEmpty) {
        uniqueEntries[entry.date] = entry;
      }
    }

    final sorted = uniqueEntries.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    int count = 0;
    final todayStr = _todayDate();

    bool completedToday = false;
    for (final entry in sorted) {
      if (entry.date == todayStr) {
        if (entry.intake >= entry.goal) {
          completedToday = true;
        }
        break;
      }
    }

    DateTime checkDate = completedToday ? DateTime.now() : DateTime.now().subtract(const Duration(days: 1));

    while (true) {
      final checkStr = checkDate.toIso8601String().split("T")[0];

      final entry = sorted.firstWhere(
            (e) => e.date == checkStr,
        orElse: () => WaterTrackerModel(userId: "", date: "", intake: -1, goal: 1),
      );

      if (entry.intake >= entry.goal) {
        count++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    if (completedToday) {
      count++;
    }

    return count;
  }
}