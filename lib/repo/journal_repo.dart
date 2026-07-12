import '../model/journal_model.dart';

abstract class JournalRepo {
  Future<void> addJournal(JournalModel journal);
  Stream<List<JournalModel>> getJournals();
  Future<void> updateJournal(JournalModel journal);
  Future<void> deleteJournal(String id);
}
