import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/user_model_mood.dart';
import '../model/journal_model.dart';
import 'admin_wellness_repo.dart';

class AdminWellnessRepoImpl implements AdminWellnessRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Stream<List<UserModelMood>> getAllMoodLogs() {
    return _firestore.collectionGroup('mood_logs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModelMood.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<UserModelMood>> getMoodLogsForUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('mood_logs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModelMood.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<JournalModel>> getAllJournals() {
    return _firestore.collection('journals').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => JournalModel.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<void> deleteJournal(String id) async {
    await _firestore.collection('journals').doc(id).delete();
  }
}
