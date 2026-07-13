import 'dart:async';
import 'package:flutter/material.dart';
import '../model/mood_model.dart';
import '../repo/mood_repo.dart';

class MoodViewModel extends ChangeNotifier {
  final MoodRepo _moodRepo;
  StreamSubscription<List<MoodLogModel>>? _moodSubscription;

  List<MoodLogModel> _moodLogs = [];
  bool _isLoading = false;

  MoodViewModel({required MoodRepo moodRepo}) : _moodRepo = moodRepo;

  List<MoodLogModel> get moodLogs => _moodLogs;

  /// Alias — WellnessDashboardScreen/MoodCalendarScreen read `viewModel.moodHistory`
  List<MoodLogModel> get moodHistory => _moodLogs;

  bool get isLoading => _isLoading;

  void fetchUserMoodLogs(String userId) {
    _isLoading = true;
    notifyListeners();
    _moodSubscription?.cancel();
    _moodSubscription = _moodRepo.streamUserMoodLogs(userId).listen((logs) {
      _moodLogs = logs;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Alias — screens call `initUserSync(userId)` on initState
  void initUserSync(String userId) => fetchUserMoodLogs(userId);

  Future<void> logMood({
    required String userId,
    required String moodType,
    required String note,
    required List<String> factors,
  }) async {
    final moodLog = MoodLogModel(
      id: '',
      userId: userId,
      moodType: moodType,
      note: note,
      factors: factors,
      timestamp: DateTime.now(),
    );
    await _moodRepo.addMoodLog(moodLog);
  }

  int get currentStreak {
    if (_moodLogs.isEmpty) return 0;
    int streak = 0;
    DateTime cursor = DateTime.now();
    final loggedDays = _moodLogs
        .map((log) =>
        DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day))
        .toSet();

    while (loggedDays.contains(DateTime(cursor.year, cursor.month, cursor.day))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get longestStreak {
    if (_moodLogs.isEmpty) return 0;
    final sortedDays = _moodLogs
        .map((log) =>
        DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day))
        .toSet()
        .toList()
      ..sort();

    int longest = 1;
    int current = 1;
    for (int i = 1; i < sortedDays.length; i++) {
      final diff = sortedDays[i].difference(sortedDays[i - 1]).inDays;
      if (diff == 1) {
        current++;
        longest = current > longest ? current : longest;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return longest;
  }

  Map<String, int> get moodCounts {
    Map<String, int> counts = {};
    for (var log in _moodLogs) {
      counts[log.moodType] = (counts[log.moodType] ?? 0) + 1;
    }
    return counts;
  }

  @override
  void dispose() {
    _moodSubscription?.cancel();
    super.dispose();
  }
}