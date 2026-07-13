import 'package:flutter/material.dart';
import '../model/journal_model.dart';
import '../repo/journal_repo.dart';

class JournalViewModel extends ChangeNotifier {
  final JournalRepo repo;

  JournalViewModel({required this.repo});

  Stream<List<JournalModel>> getJournals(String userId) => repo.getJournals(userId);

  Future<void> addJournal(JournalModel journal) async {
    await repo.addJournal(journal);
    notifyListeners();
  }

  Future<void> updateJournal(JournalModel journal) async {
    await repo.updateJournal(journal);
    notifyListeners();
  }

  Future<void> deleteJournal(String userId, String id) async {
    await repo.deleteJournal(userId, id);
    notifyListeners();
  }
}