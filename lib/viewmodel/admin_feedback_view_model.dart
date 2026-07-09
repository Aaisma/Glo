import 'package:flutter/material.dart';
import 'package:glo/model/feedback_model.dart';
import 'package:glo/repo/feedback_repo.dart';

class AdminFeedbackViewModel extends ChangeNotifier {
  final FeedbackRepo repository;

  List<FeedbackModel> _feedbacks = [];
  bool _isLoading = false;

  List<FeedbackModel> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;

  AdminFeedbackViewModel({required this.repository});

  Future<void> fetchAllFeedbacks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await repository.getAllUserFeedback();
      _feedbacks = data.map((doc) {
        return FeedbackModel.fromJson(doc, docId: doc['id']);
      }).toList();
    } catch (e) {
      debugPrint("Admin MVVM Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String feedbackId, String newStatus) async {
    try {
      await repository.updateFeedbackStatus(feedbackId, newStatus);

      final index = _feedbacks.indexWhere((element) => element.id == feedbackId);
      if (index != -1) {
        _feedbacks[index] = FeedbackModel(
          id: _feedbacks[index].id,
          category: _feedbacks[index].category,
          type: _feedbacks[index].type,
          message: _feedbacks[index].message,
          ratingIndex: _feedbacks[index].ratingIndex,
          timestamp: _feedbacks[index].timestamp,
          status: newStatus,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Admin MVVM Update Error: $e");
    }
  }
}