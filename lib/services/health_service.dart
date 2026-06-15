import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/health_model.dart';

class HealthService {
  final _db = FirebaseFirestore.instance;

  Future<void> addHealthItem(HealthModel item, String userId) async {
    final docRef = _db.collection('health').doc();
    item.id = docRef.id;
    await docRef.set({
      ...item.toMap(),
      'userId': userId,
    });
  }

  Future<List<HealthModel>> getHealthItems(String userId) async {
    final snapshot = await _db
        .collection('health')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => HealthModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateHealthItem(HealthModel item) async {
    await _db.collection('health').doc(item.id).update(item.toMap());
  }

  Future<void> deleteHealthItem(String id) async {
    await _db.collection('health').doc(id).delete();
  }
}
