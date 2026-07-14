import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/water_history_model.dart';

class WaterHistoryRepoImpl {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> saveDaily(String userId, WaterHistoryModel model) async {
    await firestore
        .collection("water_history")
        .doc(userId)
        .collection("days")
        .doc(model.date)
        .set(model.toMap());
  }

  Future<List<WaterHistoryModel>> getHistory(String userId) async {
    final snapshot = await firestore
        .collection("water_history")
        .doc(userId)
        .collection("days")
        .orderBy("date", descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return WaterHistoryModel.fromMap(doc.id, doc.data());
    }).toList();
  }
}