import '../model/journal_entry_model.dart';

abstract class JournalRepo {
  Future<void> addJournal(JournalEntryModel journal);
  Stream<List<JournalEntryModel>> getJournals(String userId);
  Future<void> updateJournal(JournalEntryModel journal);
  Future<void> deleteJournal(String userId, String journalId);
}
