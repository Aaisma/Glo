import 'package:flutter/material.dart';
import '../model/journal_entry_model.dart';
import '../repo/journal_repo_impl.dart';

class JournalEntryViewModel extends ChangeNotifier {
  final JournalRepoImpl _repo = JournalRepoImpl();
  bool isLoading = false;

  Future<bool> uploadJournalEntry({
    required String journalText,
    required String quickPrompt,
    required Map<String, String> currentActivities,
  }) async {
    isLoading = true;
    notifyListeners();

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: journalText,
      prompt: quickPrompt,
      activities: currentActivities,
      createdAt: DateTime.now(),
    );

    final success = await _repo.saveEntry(entry);

    isLoading = false;
    notifyListeners();
    return success;
  }

  Stream<List<JournalEntry>> getEntries() => _repo.getEntries();
}
