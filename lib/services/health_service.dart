import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/health_model.dart';
import 'history_builder.dart';

class HealthService {
  final FirebaseFirestore _db;

  HealthService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _healthRef =>
      _db.collection('derma_visits');

  CollectionReference<Map<String, dynamic>> get _historyRef =>
      _db.collection('history');

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

  Map<String, dynamic>? _buildHistory({
    required String healthItemId,
    required Map<String, dynamic> data,
    required String action,
  }) {
    return HistoryBuilder.build(
      // "visits" is used because HistoryBuilder handles visit records.
      collectionName: 'visits',
      docId: healthItemId,
      data: data,
      action: action,
    );
  }

  void _addHistoryToBatch({
    required WriteBatch batch,
    required String healthItemId,
    required Map<String, dynamic> data,
    required String action,
  }) {
    final historyData = _buildHistory(
      healthItemId: healthItemId,
      data: data,
      action: action,
    );

    if (historyData == null) {
      return;
    }

    // Creates a unique history document every time.
    final historyDocRef = _historyRef.doc();

    batch.set(historyDocRef, {
      ...historyData,
      'id': historyDocRef.id,
      'relatedId': healthItemId,
      'relatedCollection': 'derma_visits',
    });
  }

  Future<void> addHealthItem(
      HealthModel item,
      String userId,
      ) async {
    _validateUserId(userId);

    final docRef = _healthRef.doc();

    item.id = docRef.id;
    item.userId = userId;

    final healthData = <String, dynamic>{
      ...item.toMap(),
      'id': docRef.id,
      'userId': userId,
    };

    final batch = _db.batch();

    batch.set(docRef, {
      ...healthData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    _addHistoryToBatch(
      batch: batch,
      healthItemId: docRef.id,
      data: healthData,
      action: 'created',
    );

    await batch.commit();
  }

  Future<void> updateHealthItem(
      HealthModel item,
      String userId,
      ) async {
    _validateUserId(userId);
    _validateHealthItemId(item.id);

    item.userId = userId;

    final healthItemId = item.id!;

    final healthData = <String, dynamic>{
      ...item.toMap(),
      'id': healthItemId,
      'userId': userId,
    };

    final batch = _db.batch();

    batch.set(
      _healthRef.doc(healthItemId),
      {
        ...healthData,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    _addHistoryToBatch(
      batch: batch,
      healthItemId: healthItemId,
      data: healthData,
      action: 'updated',
    );

    await batch.commit();
  }

  Future<void> deleteHealthItem(String id) async {
    _validateHealthItemId(id);

    final docRef = _healthRef.doc(id);
    final snapshot = await docRef.get();

    final batch = _db.batch();

    if (snapshot.exists) {
      final healthData = snapshot.data();

      if (healthData != null) {
        _addHistoryToBatch(
          batch: batch,
          healthItemId: id,
          data: {
            ...healthData,
            'id': id,
          },
          action: 'deleted',
        );
      }
    }

    batch.delete(docRef);

    await batch.commit();
  }

  Future<List<HealthModel>> getHealthItems(String userId) async {
    _validateUserId(userId);

    final snapshot = await _healthRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => HealthModel.fromMap(
        doc.data(),
        doc.id,
      ),
    )
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
          .map(
            (doc) => HealthModel.fromMap(
          doc.data(),
          doc.id,
        ),
      )
          .toList(),
    );
  }

  Stream<int> getHealthItemCountStream(String userId) {
    _validateUserId(userId);

    return _healthRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.length,
    );
  }

  Stream<int> getAllHealthItemCountStream() {
    return _healthRef.snapshots().map(
          (snapshot) => snapshot.docs.length,
    );
  }

  // Kept so existing UI and ViewModel code does not break.
  Stream<List<HealthModel>> watchHealthItems(String userId) {
    return getHealthItemsStream(userId);
  }

  // Kept so existing UI and ViewModel code does not break.
  Stream<int> watchHealthCount() {
    return getAllHealthItemCountStream();
  }
}