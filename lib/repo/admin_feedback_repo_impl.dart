import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/admin_feedback_model.dart';
import 'admin_feedback-repo.dart';

/// Firestore implementation of AdminFeedbackRepo
class AdminFeedbackRepoImpl implements AdminFeedbackRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = "admin_feedback";

  @override
  Future<List<AdminFeedbackModel>> getAllFeedback() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => AdminFeedbackModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<AdminFeedbackModel?> getFeedbackById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return AdminFeedbackModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> addFeedback(AdminFeedbackModel feedback) async {
    await _firestore.collection(_collection).add(feedback.toMap());
  }

  @override
  Future<void> updateFeedback(AdminFeedbackModel feedback) async {
    await _firestore.collection(_collection).doc(feedback.id).update(feedback.toMap());
  }

  @override
  Future<void> deleteFeedback(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<void> addScore(String id, Map<String, dynamic> scoreData) async {
    await _firestore.collection(_collection).doc(id).update({
      "scores": FieldValue.arrayUnion([scoreData])
    });
  }

  @override
  Future<Map<String, dynamic>> getScoreSummary() async {
    final snapshot = await _firestore.collection(_collection).get();
    int totalFeedback = snapshot.docs.length;
    double avgScore = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey("scores")) {
        final scores = List<Map<String, dynamic>>.from(data["scores"]);
        for (var score in scores) {
          avgScore += (score["value"] ?? 0).toDouble();
        }
      }
    }

    return {
      "totalFeedback": totalFeedback,
      "averageScore": totalFeedback > 0 ? avgScore / totalFeedback : 0.0,
    };
  }
}
