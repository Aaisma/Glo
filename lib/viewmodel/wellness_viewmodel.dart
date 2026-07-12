import 'dart:async';
import 'package:flutter/material.dart';
import '../model/user_model_mood.dart';
import '../repo/mood_repo.dart';

class WellnessViewModel extends ChangeNotifier {
  final MoodRepo _repository;
  StreamSubscription? _moodSubscription;

  WellnessViewModel({required MoodRepo moodRepo}) : _repository = moodRepo;

  List<UserModelMood> _moodHistory = [];
  final String _userName = "Shiny";
  int _currentStreak = 0;
  int _longestStreak = 0;

  List<UserModelMood> get moodHistory => _moodHistory;
  String get userName => _userName;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;

  void initUserSync(String userId) {
    _moodSubscription?.cancel();
    _moodSubscription = _repository.streamUserMoodLogs(userId).listen((logs) {
      _moodHistory = logs;
      _calculateStreaks();
      notifyListeners();
    });
  }

  Future<void> logMood({
    required String userId,
    required String mood,
    required String note,
    required List<String> factors,
  }) async {
    try {
      await _repository.addMoodLog(
        userId: userId,
        moodType: mood,
        note: note,
        factors: factors,
      );
    } catch (e) {
      debugPrint("Firebase Write Failure: $e");
      rethrow;
    }
  }

  void _calculateStreaks() {
    if (_moodHistory.isEmpty) {
      _currentStreak = 0;
      _longestStreak = 0;
      return;
    }

    final distinctDays = _moodHistory
        .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (distinctDays.first.isBefore(yesterday)) {
      _currentStreak = 0;
    } else {
      int streakCount = 1;
      for (int i = 0; i < distinctDays.length - 1; i++) {
        if (distinctDays[i].difference(distinctDays[i + 1]).inDays == 1) {
          streakCount++;
        } else if (distinctDays[i].difference(distinctDays[i + 1]).inDays > 1) {
          break;
        }
      }
      _currentStreak = streakCount;
    }

    int maxStreak = 0;
    int currentRun = 1;

    if (distinctDays.length == 1) maxStreak = 1;

    for (int i = 0; i < distinctDays.length - 1; i++) {
      if (distinctDays[i].difference(distinctDays[i + 1]).inDays == 1) {
        currentRun++;
      } else if (distinctDays[i].difference(distinctDays[i + 1]).inDays > 1) {
        if (currentRun > maxStreak) maxStreak = currentRun;
        currentRun = 1;
      }
    }
    if (currentRun > maxStreak) maxStreak = currentRun;
    _longestStreak = maxStreak;
  }

  @override
  void dispose() {
    _moodSubscription?.cancel();
    super.dispose();
  }
}
