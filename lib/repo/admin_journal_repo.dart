import '../model/journal_model.dart';

abstract class AdminJournalRepo {
  Stream<List<JournalModel>> getAllJournals();
  Future<void> deleteJournal(String id);
  Future<void> updateJournalStatus(String id, Map<String, dynamic> updates);
}
