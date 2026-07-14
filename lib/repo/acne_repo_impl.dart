import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/acne_tracker_model.dart';
import 'acne_repo.dart';

class AcneRepoImpl implements AcneRepo {
  final FirebaseFirestore _firestore;

  AcneRepoImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveEntry(AcneTrackerModel model) async {
    await _firestore
        .collection("users")
        .doc(model.userId)
        .collection("acne_tracker")
        .doc(model.date)
        .set(model.toMap());
  }

  @override
  Future<AcneTrackerModel?> getEntry(String userId, String date) async {
    final doc = await _firestore
        .collection("users")
        .doc(userId)
        .collection("acne_tracker")
        .doc(date)
        .get();
    if (!doc.exists) return null;
    return AcneTrackerModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<List<AcneTrackerModel>> getAllEntries(String userId) async {
    final snapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("acne_tracker")
        .get();
    return snapshot.docs
        .map((doc) => AcneTrackerModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> deleteEntry(String userId, String date) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("acne_tracker")
        .doc(date)
        .delete();
  }
}