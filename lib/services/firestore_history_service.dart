import 'package:cloud_firestore/cloud_firestore.dart';

import 'history_builder.dart';

class FirestoreHistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Set<String> _historyCollections = {
    'medications',
    'visits',
    'journals',
    'journal',
    'cycle',
    'cycles',
    'acne',
    'acne_records',
    'mood',
    'moods',
    'images',
    'skin_images',
  };

  CollectionReference<Map<String, dynamic>> _collection(String name) {
    return _db.collection(name);
  }

  Future<String> addDocument({
    required String collectionName,
    required Map<String, dynamic> data,
    bool createHistory = true,
  }) async {
    final docRef = _collection(collectionName).doc();

    final dataWithTimestamps = {
      ...data,
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final batch = _db.batch();

    batch.set(docRef, dataWithTimestamps);

    if (createHistory && _historyCollections.contains(collectionName)) {
      final historyData = HistoryBuilder.build(
        collectionName: collectionName,
        docId: docRef.id,
        data: data,
        action: 'created',
      );

      if (historyData != null) {
        final historyId = historyData['id'] as String;
        final historyRef = _collection('history').doc(historyId);
        batch.set(historyRef, historyData);
      }
    }

    await batch.commit();

    return docRef.id;
  }

  Future<void> setDocument({
    required String collectionName,
    required String docId,
    required Map<String, dynamic> data,
    bool createHistory = true,
    bool merge = true,
  }) async {
    final docRef = _collection(collectionName).doc(docId);

    final dataWithTimestamps = {
      ...data,
      'id': docId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final batch = _db.batch();

    batch.set(
      docRef,
      dataWithTimestamps,
      SetOptions(merge: merge),
    );

    if (createHistory && _historyCollections.contains(collectionName)) {
      final historyData = HistoryBuilder.build(
        collectionName: collectionName,
        docId: docId,
        data: data,
        action: 'updated',
      );

      if (historyData != null) {
        final historyId = historyData['id'] as String;
        final historyRef = _collection('history').doc(historyId);
        batch.set(
          historyRef,
          historyData,
          SetOptions(merge: true),
        );
      }
    }

    await batch.commit();
  }

  Future<void> updateDocument({
    required String collectionName,
    required String docId,
    required Map<String, dynamic> data,
    bool createHistory = true,
  }) async {
    final docRef = _collection(collectionName).doc(docId);

    final dataWithTimestamps = {
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final batch = _db.batch();

    batch.update(docRef, dataWithTimestamps);

    if (createHistory && _historyCollections.contains(collectionName)) {
      final historyData = HistoryBuilder.build(
        collectionName: collectionName,
        docId: docId,
        data: data,
        action: 'updated',
      );

      if (historyData != null) {
        final historyId = historyData['id'] as String;
        final historyRef = _collection('history').doc(historyId);
        batch.set(
          historyRef,
          historyData,
          SetOptions(merge: true),
        );
      }
    }

    await batch.commit();
  }

  Future<void> deleteDocument({
    required String collectionName,
    required String docId,
  }) async {
    await _collection(collectionName).doc(docId).delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collectionName,
    required String docId,
  }) {
    return _collection(collectionName).doc(docId).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCollection({
    required String collectionName,
  }) {
    return _collection(collectionName).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream({
    required String collectionName,
  }) {
    return _collection(collectionName).snapshots();
  }

  Query<Map<String, dynamic>> query({
    required String collectionName,
  }) {
    return _collection(collectionName);
  }
}