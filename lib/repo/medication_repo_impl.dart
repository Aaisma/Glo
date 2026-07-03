import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/medication_model.dart';
import 'medication_repo.dart';

class MedicationRepoImpl implements MedicationRepo {
  final FirebaseFirestore _db;

  MedicationRepoImpl({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _medicationsRef =>
      _db.collection('medications');

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required.');
    }
  }

  void _validateMedicationId(String? id) {
    if (id == null || id.trim().isEmpty) {
      throw Exception('Medication ID is required.');
    }
  }

  @override
  Future<void> addMedication(
      MedicationModel medication,
      String userId,
      ) async {
    _validateUserId(userId);

    final docRef = _medicationsRef.doc();

    medication.id = docRef.id;
    medication.userId = userId;

    await docRef.set({
      ...medication.toMap(),
      'id': docRef.id,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateMedication(
      MedicationModel medication,
      String userId,
      ) async {
    _validateUserId(userId);
    _validateMedicationId(medication.id);

    medication.userId = userId;

    await _medicationsRef.doc(medication.id).set({
      ...medication.toMap(),
      'userId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteMedication(String medicationId) async {
    _validateMedicationId(medicationId);

    await _medicationsRef.doc(medicationId).delete();
  }

  @override
  Future<List<MedicationModel>> getMedications(String userId) async {
    _validateUserId(userId);

    final snapshot = await _medicationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MedicationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Stream<List<MedicationModel>> getMedicationsStream(String userId) {
    _validateUserId(userId);

    return _medicationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => MedicationModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  @override
  Stream<int> getMedicationCountStream(String userId) {
    _validateUserId(userId);

    return _medicationsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Stream<int> getAllMedicationCountStream() {
    return _medicationsRef.snapshots().map((snapshot) => snapshot.docs.length);
  }
}