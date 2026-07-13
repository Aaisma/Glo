import 'package:flutter/material.dart';
import '../model/journal_model.dart';
import '../repo/journal_repo.dart';

class JournalFavoritesViewModel extends ChangeNotifier {
  final JournalRepo repository;

  JournalFavoritesViewModel({required this.repository});

  /// Returns a real-time stream of journals filtered by isFavorite = true
  Stream<List<JournalModel>> getFavoritesStream(String userId) {
    return repository.getJournals(userId).map(
      (journals) => journals.where((j) => j.isFavorite).toList(),
    );
  }

  /// Toggles the favorite status of an entry in the database
  Future<void> toggleFavorite(JournalModel journal) async {
    final updatedJournal = journal.copyWith(isFavorite: !journal.isFavorite);
    await repository.updateJournal(updatedJournal);
    // No need to notifyListeners() here if using StreamBuilder in UI, 
    // as the stream will emit a new event when the DB updates.
  }
}
