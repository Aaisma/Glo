import '../model/mood_model.dart';

abstract class MoodRepo {
  Stream<List<MoodLogModel>> streamUserMoodLogs(String userId);
  Future<void> addMoodLog(MoodLogModel moodLog);
}