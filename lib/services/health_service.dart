import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/health_model.dart';

class HealthService {
  final FirebaseFirestore _db;

  HealthService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _healthRef =>
      _db.collection('derma_visits');

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required.');
    }
  }

  void _validateHealthItemId(String? id) {
    if (id == null || id.trim().isEmpty) {
      throw Exception('Health item ID is required.');
    }
  }

  Future<void> addHealthItem(
      HealthModel item,
      String userId,
      ) async {
    _validateUserId(userId);

    final docRef = _healthRef.doc();

    item.id = docRef.id;
    item.userId = userId;

    await docRef.set({
      ...item.toMap(),
      'id': docRef.id,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateHealthItem(
      HealthModel item,
      String userId,
      ) async {
    _validateUserId(userId);
    _validateHealthItemId(item.id);

    item.userId = userId;

    await _healthRef.doc(item.id).set({
      ...item.toMap(),
      'userId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteHealthItem(String id) async {
    _validateHealthItemId(id);

    await _healthRef.doc(id).delete();
  }

  Future<List<HealthModel>> getHealthItems(String userId) async {
    _validateUserId(userId);

    final snapshot = await _healthRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HealthModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<HealthModel>> getHealthItemsStream(String userId) {
    _validateUserId(userId);

    return _healthRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => HealthModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Stream<int> getHealthItemCountStream(String userId) {
    _validateUserId(userId);

    return _healthRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getAllHealthItemCountStream() {
    return _healthRef.snapshots().map((snapshot) => snapshot.docs.length);
  }

  // Existing method kept so current UI code does not break.
  Stream<List<HealthModel>> watchHealthItems(String userId) {
    return getHealthItemsStream(userId);
  }

  // Existing method kept so current UI code does not break.
  Stream<int> watchHealthCount() {
    return getAllHealthItemCountStream();
  }
}