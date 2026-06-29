import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/meal_entry_model.dart';
import 'meal_repo.dart';

class MealRepoImpl implements MealRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveEntry(MealEntryModel model) async {
    await _firestore
        .collection("users")
        .doc(model.userId)
        .collection("meal_tracker")
        .doc(model.date)
        .set(model.toMap());
  }

  @override
  Future<MealEntryModel?> getEntry(String userId, String date) async {
    final doc = await _firestore
        .collection("users")
        .doc(userId)
        .collection("meal_tracker")
        .doc(date)
        .get();
    if (!doc.exists) return null;
    return MealEntryModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<List<MealEntryModel>> getAllEntries(String userId) async {
    final snapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("meal_tracker")
        .get();
    return snapshot.docs.map((doc) => MealEntryModel.fromMap(doc.id, doc.data())).toList();
  }

  @override
  Future<void> deleteEntry(String userId, String date) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("meal_tracker")
        .doc(date)
        .delete();
  }
}