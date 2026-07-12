import 'package:glo/model/user_model.dart';
import 'package:glo/model/user_model_mood.dart';
import 'package:glo/model/journal_model.dart';

abstract class AdminWellnessRepo {
  Stream<List<UserModel>> getAllUsers();
  Stream<List<UserModelMood>> getAllMoodLogs();
  Stream<List<UserModelMood>> getMoodLogsForUser(String userId);
  Stream<List<JournalModel>> getAllJournals();
  Future<void> deleteJournal(String id);
}
