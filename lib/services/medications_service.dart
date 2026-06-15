import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/medication_model.dart';

class MedicationsService {
  final _db = FirebaseFirestore.instance;

  Future<void> addMedication(MedicationModel med, String userId) async {
    final docRef = _db.collection('medications').doc();
    med.id = docRef.id;
    await docRef.set({
      ...med.toMap(),
      'userId': userId,
    });
  }

  Future<List<MedicationModel>> getMedications(String userId) async {
    final snapshot = await _db
        .collection('medications')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => MedicationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateMedication(MedicationModel med) async {
    await _db.collection('medications').doc(med.id).update(med.toMap());
  }

  Future<void> deleteMedication(String id) async {
    await _db.collection('medications').doc(id).delete();
  }
}
