import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/feedback_model.dart';
import 'feedback_repo.dart';

class FeedbackRepoImpl implements FeedbackRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> submitFeedback(FeedbackModel feedback) async {
    try {
      await _firestore.collection('feedback').add(feedback.toJson());
      print("✅ Feedback submitted successfully!");
    } catch (e) {
      print("❌ Error submitting feedback: $e");
      rethrow;
    }
  }

  @override
  Future<List<FeedbackModel>> fetchFeedbackHistory() async {
    try {
      final snapshot = await _firestore
          .collection('feedback')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return FeedbackModel.fromJson(doc.data());
      }).toList();
    } catch (e) {
      print("❌ Error fetching feedback history: $e");
      rethrow;
    }
  }

  @override
  Stream<List<FeedbackModel>> getFeedbackStream() {
    return _firestore
        .collection('feedback')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FeedbackModel.fromJson(doc.data());
      }).toList();
    });
  }
}
