import '../model/insight_models.dart';

abstract class InsightsPollRepo {
Future<List<InsightPoll>> getAllAdminPolls();
  Future<InsightPoll?> getPollById(String id);
  Future<void> savePollDraft(InsightPoll poll);
  Future<InsightPoll?> getPollDraft(String id);
  Future<void> discardPollDraft(String id);
  Future<void> publishPoll(InsightPoll poll);
  Future<void> updatePoll(InsightPoll poll);
  Future<void> archivePoll(String id);
  Future<void> deletePoll(String id);
}