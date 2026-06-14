import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/water_history_model.dart';
import 'water_history_repo.dart';

class WaterHistoryRepoImpl implements WaterHistoryRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String uid = "demo_user"; // later we replace with real login UID

  @override
  Future<void> saveToday(WaterHistoryModel model) async {
    await firestore
        .collection("users")
        .doc(uid)
        .collection("water_history")
        .doc(model.date)
        .set(model.toMap());
  }

  @override
  Future<List<WaterHistoryModel>> getHistory() async {
    final snapshot = await firestore
        .collection("users")
        .doc(uid)
        .collection("water_history")
        .get();

    return snapshot.docs.map((doc) {
      return WaterHistoryModel.fromMap(doc.id, doc.data());
    }).toList();
  }
}