import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/visit_model.dart';

class VisitsService {
  final _db = FirebaseFirestore.instance;

  Future<void> addVisit(VisitModel visit, String userId) async {
    final docRef = _db.collection('visits').doc();
    visit.id = docRef.id;
    await docRef.set({
      ...visit.toMap(),
      'userId': userId,
    });
  }

  Future<List<VisitModel>> getVisits(String userId) async {
    final snapshot = await _db
        .collection('visits')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => VisitModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateVisit(VisitModel visit) async {
    await _db.collection('visits').doc(visit.id).update(visit.toMap());
  }

  Future<void> deleteVisit(String id) async {
    await _db.collection('visits').doc(id).delete();
  }
}
