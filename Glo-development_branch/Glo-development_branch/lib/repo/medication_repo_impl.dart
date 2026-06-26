import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/medication_model.dart';
import 'medication_repo.dart';

class MedicationRepoImpl implements MedicationRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<void> addMedication(MedicationModel med, String userId) async {
    final docRef = _db.collection('users').doc(userId).collection('medications').doc();
    med.id = docRef.id; // ensure MedicationModel has an id field
    await docRef.set(med.toMap());
  }

  @override
  Future<void> updateMedication(MedicationModel med, String userId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('medications')
        .doc(med.id)
        .update(med.toMap());
  }

  @override
  Future<void> deleteMedication(String userId, String id) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('medications')
        .doc(id)
        .delete();
  }

  @override
  Future<List<MedicationModel>> getMedications(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('medications')
        .get();

    return snapshot.docs
        .map((doc) => MedicationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Stream<List<MedicationModel>> getMedicationsStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('medications')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => MedicationModel.fromMap(doc.data(), doc.id)).toList());
  }
}
