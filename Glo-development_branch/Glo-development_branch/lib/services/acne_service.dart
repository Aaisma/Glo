import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/acne_tracker_model.dart';

class AcneService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String uid;

  AcneService({required this.uid});

  CollectionReference get _ref =>
      firestore.collection("users").doc(uid).collection("acne_tracker");

  Future<void> save(AcneTrackerModel model) async {
    await _ref.doc(model.date).set(model.toMap());
  }

  Future<AcneTrackerModel?> getToday(String date) async {
    final doc = await _ref.doc(date).get();

    if (!doc.exists) return null;

    return AcneTrackerModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}