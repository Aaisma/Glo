import 'package:glo/model/feedback_model.dart';

abstract class FeedbackRepo {
  Future<void> submitFeedback(FeedbackModel feedback);
  Future<List<FeedbackModel>> fetchFeedbackHistory();
  Stream<List<FeedbackModel>>? getFeedbackStream();

  Future<List<Map<String, dynamic>>> getAllUserFeedback();
  Future<void> updateFeedbackStatus(String feedbackId, String status);
}