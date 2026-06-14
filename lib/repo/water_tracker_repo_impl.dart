import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/water_tracker_model.dart';
import 'water_tracker_repo.dart';

class WaterTrackerRepoImpl implements WaterTrackerRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String docId = "water_tracker";

  @override
  Future<void> saveWater(WaterTrackerModel model) async {
    await _firestore
        .collection("water_tracker")
        .doc(docId)
        .set(model.toMap());
  }

  @override
  Future<WaterTrackerModel?> getWater() async {
    final doc = await _firestore
        .collection("water_tracker")
        .doc(docId)
        .get();

    if (doc.exists) {
      return WaterTrackerModel.fromMap(doc.data()!);
    }
    return null;
  }
}