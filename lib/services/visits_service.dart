// lib/services/visits_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glo/model/visit_model.dart';

class VisitsService {
  final _db = FirebaseFirestore.instance;

  /// Add a new visit for a user
  Future<void> addVisit(Visit visit, String userId) async {
    await _db.collection('visits').doc(visit.id).set({
      ...visit.toMap(),
      'userId': userId,
    });
  }

  /// Fetch all visits for a given user (real-time stream)
  Stream<List<Visit>> fetchVisits(String userId) {
    return _db
        .collection('visits')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Visit.fromMap(doc.data(), doc.id)).toList());
  }

  /// Update an existing visit
  Future<void> updateVisit(Visit visit) async {
    await _db.collection('visits').doc(visit.id).update(visit.toMap());
  }

  /// Delete a visit by ID
  Future<void> deleteVisit(String id) async {
    await _db.collection('visits').doc(id).delete();
  }
}
