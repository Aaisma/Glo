import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/nutrition_entry_model.dart';
import 'nutrition_repo.dart';

class NutritionRepoImpl implements NutritionRepo {
  final FirebaseFirestore _firestore;

  NutritionRepoImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveEntry(NutritionEntryModel model) async {
    await _firestore
        .collection("users")
        .doc(model.userId)
        .collection("meal_tracker") // Keeping the collection name for data continuity
        .doc(model.date)
        .set(model.toMap());
  }

  @override
  Future<NutritionEntryModel?> getEntry(String userId, String date) async {
    final doc = await _firestore
        .collection("users")
        .doc(userId)
        .collection("meal_tracker")
        .doc(date)
        .get();
    if (!doc.exists) return null;
    return NutritionEntryModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<List<NutritionEntryModel>> getAllEntries(String userId) async {
    final snapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("meal_tracker")
        .orderBy("date", descending: true)
        .get();
    return snapshot.docs.map((doc) => NutritionEntryModel.fromMap(doc.id, doc.data())).toList();
  }
}
