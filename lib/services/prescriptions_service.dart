// lib/services/prescriptions_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glo/model/prescription_model.dart';

class PrescriptionsService {
  final _db = FirebaseFirestore.instance;

  /// Add a new prescription for a user
  Future<void> addPrescription(Prescription prescription, String userId) async {
    await _db.collection('prescriptions').doc(prescription.id).set({
      ...prescription.toMap(),
      'userId': userId,
    });
  }

  /// Fetch all prescriptions for a given user (real-time stream)
  Stream<List<Prescription>> fetchPrescriptions(String userId) {
    return _db
        .collection('prescriptions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Prescription.fromMap(doc.data(), doc.id)).toList());
  }

  /// Update an existing prescription
  Future<void> updatePrescription(Prescription prescription) async {
    await _db.collection('prescriptions').doc(prescription.id).update(prescription.toMap());
  }

  /// Delete a prescription by ID
  Future<void> deletePrescription(String id) async {
    await _db.collection('prescriptions').doc(id).delete();
  }
}
