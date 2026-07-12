import 'package:flutter/material.dart';
import 'package:glo/model/admin_feedback_model.dart';
import 'package:glo/repo/feedback_repo.dart';

class AdminFeedbackViewModel extends ChangeNotifier {
  final FeedbackRepo repository;

  List<AdminFeedbackModel> _feedbacks = [];
  bool _isLoading = false;
  AdminFeedbackModel? _selectedItem;

  List<AdminFeedbackModel> get feedbacks => _feedbacks;
  List<AdminFeedbackModel> get items => _feedbacks; 
  bool get isLoading => _isLoading;
  AdminFeedbackModel? get selectedItem => _selectedItem;

  // Dashboard Metrics
  int get totalCount => _feedbacks.length;
  
  double get averageScore {
    if (_feedbacks.isEmpty) return 0.0;
    double sum = _feedbacks.fold(0, (prev, element) => prev + element.overallScore);
    return sum / _feedbacks.length;
  }

  int get positiveCount => _feedbacks.where((e) => e.ratingIndex >= 3).length; // 4 and 5 stars
  int get negativeCount => _feedbacks.where((e) => e.ratingIndex <= 1).length; // 1 and 2 stars

  AdminFeedbackViewModel({required this.repository}) {
    loadAllFeedback();
  }

  Future<void> loadAllFeedback() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await repository.getAllUserFeedback();
      _feedbacks = data.map((doc) {
        return AdminFeedbackModel.fromJson(doc, docId: doc['id']);
      }).toList();
    } catch (e) {
      debugPrint("Admin Feedback Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectItem(AdminFeedbackModel item) {
    _selectedItem = item;
    notifyListeners();
  }

  Future<void> updateFeedbackStatus(String? feedbackId, String newStatus) async {
    if (feedbackId == null) return;
    
    try {
      await repository.updateFeedbackStatus(feedbackId, newStatus);
      
      final index = _feedbacks.indexWhere((element) => element.id == feedbackId);
      if (index != -1) {
        final old = _feedbacks[index];
        _feedbacks[index] = old.copyWith(status: newStatus);
        
        if (_selectedItem?.id == feedbackId) {
          _selectedItem = _feedbacks[index];
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Admin Feedback Update Error: $e");
    }
  }
}
