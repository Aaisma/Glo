import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/water_tracker_model.dart';
import 'water_tracker_repo.dart';

class WaterTrackerRepoImpl implements WaterTrackerRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveEntry(WaterTrackerModel model) async {
    await _firestore
        .collection("users")
        .doc(model.userId)
        .collection("water_history")
        .doc(model.date)
        .set(model.toMap());
  }

  @override
  Future<WaterTrackerModel?> getEntry(String userId, String date) async {
    final doc = await _firestore
        .collection("users")
        .doc(userId)
        .collection("water_history")
        .doc(date)
        .get();
    if (!doc.exists) return null;
    return WaterTrackerModel.fromMap(doc.data()!);
  }
}