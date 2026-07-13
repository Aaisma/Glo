import 'dart:async';
import 'package:flutter/material.dart';

import '../model/user_model_mood.dart';
import '../repo/mood_repo.dart';
import '../repo/mood_repo_impl.dart';

class WellnessViewModel extends ChangeNotifier {
  final MoodRepo _repo;

  WellnessViewModel({MoodRepo? repo}) : _repo = repo ?? MoodRepoImpl();

  StreamSubscription<List<UserModelMood>>? _subscription;

  List<UserModelMood> moodHistory = [];

  int currentStreak = 0;
  int longestStreak = 0;

  bool isLoading = false;

  String? _currentUserId;

  void initUserSync(String userId) {
    if (_currentUserId == userId) return;

    _currentUserId = userId;
    isLoading = true;
    notifyListeners();

    _subscription?.cancel();

    _subscription = _repo.streamUserMoodLogs(userId).listen(
          (logs) {
        moodHistory = logs;
        _calculateStreaks();

        isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        debugPrint("Mood Stream Error: $error");
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> logMood({
    required String userId,
    required String mood,
    required String note,
    required List<String> factors,
  }) async {
    try {
      await _repo.addMoodLog(
        userId: userId,
        moodType: mood,
        note: note,
        factors: factors,
      );
    } catch (e) {
      debugPrint("Error logging mood: $e");
      rethrow;
    }
  }

  void _calculateStreaks() {
    if (moodHistory.isEmpty) {
      currentStreak = 0;
      longestStreak = 0;
      return;
    }

    final uniqueDays = moodHistory
        .map(
          (m) => DateTime(
        m.timestamp.year,
        m.timestamp.month,
        m.timestamp.day,
      ),
    )
        .toSet()
        .toList()
      ..sort();

    // ---------- Longest Streak ----------
    longestStreak = 1;

    int tempLongest = 1;

    for (int i = 1; i < uniqueDays.length; i++) {
      if (uniqueDays[i].difference(uniqueDays[i - 1]).inDays == 1) {
        tempLongest++;
      } else {
        tempLongest = 1;
      }

      if (tempLongest > longestStreak) {
        longestStreak = tempLongest;
      }
    }

    // ---------- Current Streak ----------
    final today = DateTime.now();
    DateTime expectedDay = DateTime(today.year, today.month, today.day);

    currentStreak = 0;

    final descendingDays = uniqueDays.reversed.toList();

    for (final day in descendingDays) {
      if (day == expectedDay) {
        currentStreak++;
        expectedDay = expectedDay.subtract(const Duration(days: 1));
      } else if (day.isBefore(expectedDay)) {
        break;
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}