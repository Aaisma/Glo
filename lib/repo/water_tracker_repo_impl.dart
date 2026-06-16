import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/water_tracker_model.dart';
import '../model/water_history_model.dart';

class WaterTrackerRepoImpl {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Save current state (latest)
  Future<void> saveData(WaterTrackerModel model) async {
    await firestore
        .collection("users")
        .doc(model.userId)
        .collection("water_tracker")
        .doc("latest")
        .set(model.toMap());
  }

  // Get latest state
  Future<WaterTrackerModel?> getData(String userId) async {
    final doc = await firestore
        .collection("users")
        .doc(userId)
        .collection("water_tracker")
        .doc("latest")
        .get();

    if (!doc.exists) return null;

    return WaterTrackerModel.fromMap(doc.id, doc.data()!);
  }

  // 🔥 SAVE DAILY HISTORY
  Future<void> saveHistory(String userId, WaterHistoryModel model) async {
    await firestore
        .collection("users")
        .doc(userId)
        .collection("water_history")
        .doc(model.date)
        .set(model.toMap());
  }

  // 📊 GET HISTORY LIST
  Future<List<WaterHistoryModel>> getHistory(String userId) async {
    final snapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("water_history")
        .orderBy("date", descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return WaterHistoryModel.fromMap(doc.id, doc.data());
    }).toList();
  }
}