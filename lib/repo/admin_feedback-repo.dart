import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/admin_feedback_model.dart';

/// Repository interface for Admin Feedback
abstract class AdminFeedbackRepo {
  Future<List<AdminFeedbackModel>> getAllFeedback();
  Future<AdminFeedbackModel?> getFeedbackById(String id);
  Future<void> addFeedback(AdminFeedbackModel feedback);
  Future<void> updateFeedback(AdminFeedbackModel feedback);
  Future<void> deleteFeedback(String id);
  Future<void> addScore(String id, Map<String, dynamic> scoreData);
  Future<Map<String, dynamic>> getScoreSummary();
}