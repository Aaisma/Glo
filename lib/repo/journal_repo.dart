import '../model/journal_model.dart';

abstract class JournalRepo {
  Future<void> addJournal(JournalModel journal);
  Stream<List<JournalModel>> getJournals(String userId);
  Future<void> updateJournal(JournalModel journal);
  Future<void> deleteJournal(String userId, String journalId);
}
