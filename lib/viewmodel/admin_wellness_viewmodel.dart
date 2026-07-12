import 'package:flutter/material.dart';
import 'package:glo/model/user_model.dart';
import 'package:glo/model/user_model_mood.dart';
import 'package:glo/model/journal_model.dart';
import 'package:glo/repo/admin_wellness_repo.dart';

class AdminWellnessViewModel extends ChangeNotifier {
  final AdminWellnessRepo repo;

  AdminWellnessViewModel({required this.repo});

  /// Streams all users for the wellness dashboard
  Stream<List<UserModel>> getAllUsers() => repo.getAllUsers();

  /// Streams all mood logs across the community
  Stream<List<UserModelMood>> getAllMoodLogs() => repo.getAllMoodLogs();

  /// Streams mood logs for a specific user
  Stream<List<UserModelMood>> getMoodLogsForUser(String userId) => repo.getMoodLogsForUser(userId);

  /// Streams all journals for review in the wellness context
  Stream<List<JournalModel>> getAllJournals() => repo.getAllJournals();

  /// Deletes a journal entry
  Future<void> deleteJournal(String id) async {
    try {
      await repo.deleteJournal(id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting journal: $e");
    }
  }
}