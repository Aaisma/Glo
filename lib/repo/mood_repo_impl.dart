import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glo/model/user_model_mood.dart';
import 'mood_repo.dart';

class MoodRepoImpl implements MoodRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<UserModelMood>> streamUserMoodLogs(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('mood_logs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModelMood.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> addMoodLog({
    required String userId,
    required String moodType,
    required String note,
    required List<String> factors,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('mood_logs')
        .add({
      'userId': userId,
      'moodType': moodType,
      'note': note,
      'factors': factors,
      'date': FieldValue.serverTimestamp(),
    });
  }
}
