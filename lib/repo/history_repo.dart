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
