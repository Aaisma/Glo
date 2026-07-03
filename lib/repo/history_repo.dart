<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/history_model.dart';


class HistoryRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<HistoryModel>> getUserHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => HistoryModel.fromMap(doc.id, doc.data()))
        .toList());
  }
}
=======
import '../model/history_model.dart';

abstract class HistoryRepo {
  Future<void> addHistory(HistoryModel history, String userId);

  Future<void> updateHistory(HistoryModel history, String userId);

  Future<void> deleteHistory(String userId, String historyId);

  Future<List<HistoryModel>> getHistory(String userId);

  Stream<List<HistoryModel>> getHistoryStream(String userId);

  Stream<int> getAllHistoryCountStream();
}
>>>>>>> Ayusha_branch
