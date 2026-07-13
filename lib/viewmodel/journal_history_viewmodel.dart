import 'package:flutter/material.dart';
import '../model/journal_entry_model.dart';
import '../repo/journal_repo.dart';

class JournalHistoryViewModel extends ChangeNotifier {
  final JournalRepo repository;
  
  JournalHistoryViewModel({required this.repository});

  /// Returns a real-time stream of journals for the specific user
  Stream<List<JournalEntryModel>> getJournalStream(String userId) {
    return repository.getJournals(userId);
  }

  /// Deletes a journal entry
  Future<void> deleteJournal(String userId, String journalId) async {
    await repository.deleteJournal(userId, journalId);
    notifyListeners();
  }
}
