import 'package:glo/model/medication_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationsService {
  final _db = FirebaseFirestore.instance;

  Future<void> addMedication(Medication medication, String userId) async {
    await _db.collection('medications').doc(medication.id).set({
      ...medication.toMap(),
      'userId': userId,
    });
  }

  Stream<List<Medication>> fetchMedications(String userId) {
    return _db
        .collection('medications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Medication.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> updateMedication(Medication medication) async {
    await _db.collection('medications').doc(medication.id).update(medication.toMap());
  }

  Future<void> deleteMedication(String id) async {
    await _db.collection('medications').doc(id).delete();
  }
}
