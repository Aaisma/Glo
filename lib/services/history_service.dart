import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/history_model.dart';

class HistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _historyRef {
    return _db.collection('history');
  }

  Future<void> addHistory(
      HistoryModel history,
      String userId,
      ) async {
    final docRef = _historyRef.doc();

    await docRef.set({
      ...history.toMap(),
      'id': docRef.id,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<HistoryModel>> getHistory(String userId) async {
    final snapshot = await _historyRef
        .where('userId', isEqualTo: userId)
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
    return _historyRef
        .where('userId', isEqualTo: userId)
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
    await _historyRef.doc(history.id).update({
      ...history.toMap(),
      'userId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteHistory(
      String userId,
      String historyId,
      ) async {
    await _historyRef.doc(historyId).delete();
  }

  Stream<int> getAllHistoryCountStream() {
    return _historyRef.snapshots().map(
          (snapshot) => snapshot.docs.length,
    );
  }

  Stream<int> getUserHistoryCountStream(String userId) {
    return _historyRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.length,
    );
  }
}