import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/medication_model.dart';

class MedicationsService {
  final FirebaseFirestore _db;

  MedicationsService({FirebaseFirestore? firestore})
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

  Future<void> addMedication(MedicationModel med, String userId) async {
    _validateUserId(userId);

    final docRef = _medicationsRef.doc();
    med.id = docRef.id;
    med.userId = userId;

    await docRef.set({
      ...med.toMap(),
      'id': docRef.id,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMedication(MedicationModel med, String userId) async {
    _validateUserId(userId);
    _validateMedicationId(med.id);

    med.userId = userId;

    await _medicationsRef.doc(med.id).set({
      ...med.toMap(),
      'userId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteMedication(String id) async {
    _validateMedicationId(id);
    await _medicationsRef.doc(id).delete();
  }

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


  Stream<List<MedicationModel>> getMedicationsStream(String userId) {
    _validateUserId(userId);

    return _medicationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => MedicationModel.fromMap(doc.data(), doc.id)).toList());
  }

  // ✅ Renamed to match repo
  Stream<int> getMedicationCountStream(String userId) {
    _validateUserId(userId);
    return _medicationsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ✅ Renamed to match repo
  Stream<int> getAllMedicationCountStream() {
    return _medicationsRef.snapshots().map((snapshot) => snapshot.docs.length);
  }
}
