import 'dart:async';
import 'package:flutter/material.dart';
import 'package:glo/model/user_model_mood.dart';
import 'package:glo/repo/mood_repo.dart';

class MoodViewModel extends ChangeNotifier {
  final MoodRepo _moodRepo;
  StreamSubscription<List<UserModelMood>>? _moodSubscription;

  List<UserModelMood> _moodLogs = [];
  bool _isLoading = false;
  String? _error;

  MoodViewModel({required MoodRepo moodRepo}) : _moodRepo = moodRepo;

  List<UserModelMood> get moodLogs => _moodLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Listen to real-time mood updates for a specific user
  void fetchMoodLogs(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _moodSubscription?.cancel();
    _moodSubscription = _moodRepo.streamUserMoodLogs(userId).listen(
      (logs) {
        _moodLogs = logs;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Add a new mood entry
  Future<void> saveMood({
    required String userId,
    required String moodType,
    required String note,
    required List<String> factors,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _moodRepo.addMoodLog(
        userId: userId,
        moodType: moodType,
        note: note,
        factors: factors,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _moodSubscription?.cancel();
    super.dispose();
  }
}
