import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/history_model.dart';

class HistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _historyRef(String userId) {
    return _db.collection('users').doc(userId).collection('history');
  }

  Future<void> addHistory(
      HistoryModel history,
      String userId,
      ) async {
    final docRef = _historyRef(userId).doc();

    await docRef.set({
      ...history.toMap(),
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<HistoryModel>> getHistory(String userId) async {
    final snapshot = await _historyRef(userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => HistoryModel.fromMap(
        doc.id,
        doc.data(),
      ),
    )
        .toList();
  }

  Stream<List<HistoryModel>> getHistoryStream(String userId) {
    return _historyRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => HistoryModel.fromMap(
          doc.id,
          doc.data(),
        ),
      )
          .toList(),
    );
  }

  Future<void> updateHistory(
      HistoryModel history,
      String userId,
      ) async {
    await _historyRef(userId)
        .doc(history.id)
        .update({
      ...history.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteHistory(
      String userId,
      String historyId,
      ) async {
    await _historyRef(userId)
        .doc(historyId)
        .delete();
  }

  Stream<int> getHistoryCountStream() {
    return _db
        .collectionGroup('history')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.length,
    );
  }

  Stream<int> getUserHistoryCountStream(String userId) {
    return _historyRef(userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.length,
    );
  }
}