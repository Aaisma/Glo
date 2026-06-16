import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/water_tracker_model.dart';

class WaterTrackerRepoImpl {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> saveData(WaterTrackerModel model) async {
    await firestore
        .collection("water_tracker")
        .doc(model.userId)
        .set(model.toMap());
  }

  Future<WaterTrackerModel?> getData(String userId) async {
    final doc = await firestore.collection("water_tracker").doc(userId).get();

    if (!doc.exists) return null;

    return WaterTrackerModel.fromMap(doc.data()!);
  }
}