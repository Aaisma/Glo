import 'package:flutter/material.dart';import 'package:glo/model/journal_model.dart';
import 'package:glo/repo/admin_journal_repo.dart';

class AdminJournalViewModel extends ChangeNotifier {
  final AdminJournalRepo repo;

  AdminJournalViewModel({required this.repo});

  /// Streams all journals for the admin to manage
  Stream<List<JournalModel>> getAllJournals() => repo.getAllJournals();

  /// Deletes a specific journal by ID
  Future<void> deleteJournal(String id) async {
    try {
      await repo.deleteJournal(id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting journal: $e");
      rethrow;
    }
  }

  /// Updates status or other fields of a journal
  Future<void> updateJournalStatus(String id, Map<String, dynamic> updates) async {
    try {
      await repo.updateJournalStatus(id, updates);
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating journal: $e");
      rethrow;
    }
  }
}