import '../model/user_model_mood.dart';

abstract class MoodRepo {
  Stream<List<UserModelMood>> streamUserMoodLogs(String userId);

  Future<void> addMoodLog({
    required String userId,
    required String moodType,
    required String note,
    required List<String> factors,
  });

  Future<void> updateUserField(String userId, Map<String, dynamic> dataToUpdate);
}