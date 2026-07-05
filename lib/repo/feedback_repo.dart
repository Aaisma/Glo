import 'package:glo/model/feedback_model.dart';

abstract class FeedbackRepo {
  Future<void> submitFeedback(FeedbackModel feedback);
  Future<List<FeedbackModel>> fetchFeedbackHistory();

  Stream<List<FeedbackModel>>? getFeedbackStream() {}
}