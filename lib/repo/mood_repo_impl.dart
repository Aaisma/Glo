import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/mood_model.dart';
import 'mood_repo.dart';

class MoodRepoImpl implements MoodRepo {
  final FirebaseFirestore _firestore;

  MoodRepoImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collection = 'mood_logs';

  @override
  Stream<List<MoodLogModel>> streamUserMoodLogs(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MoodLogModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  @override
  Future<void> addMoodLog(MoodLogModel moodLog) async {
    await _firestore.collection(_collection).add(moodLog.toMap());
  }
}