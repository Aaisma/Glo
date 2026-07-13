import 'package:flutter/material.dart';
import '../model/admin_feedback_model.dart';
import '../repo/admin_feedback-repo.dart';

class AdminFeedbackViewModel extends ChangeNotifier {
  final AdminFeedbackRepo _repository;

  AdminFeedbackViewModel({required AdminFeedbackRepo repository}) : _repository = repository;

  List<AdminFeedbackModel> _items = [];
  bool _isLoading = false;
  AdminFeedbackModel? selectedItem;

  List<AdminFeedbackModel> get feedbacks => _items;
  List<AdminFeedbackModel> get items => _items;
  bool get isLoading => _isLoading;

  int get totalCount => _items.length;
  int get positiveCount => _items.where((e) => e.overallScore >= 4.0).length;
  int get negativeCount => _items.where((e) => e.overallScore < 3.0).length;

  double get averageScore => _items.isEmpty
      ? 0.0
      : _items.map((e) => e.overallScore).reduce((a, b) => a + b) / _items.length;

  Future<void> loadAllFeedback() async {
    _isLoading = true;
    notifyListeners();
    _items = await _repository.getAllFeedback();
    _isLoading = false;
    notifyListeners();
  }

  void selectItem(AdminFeedbackModel item) {
    selectedItem = item;
    notifyListeners();
  }

  Future<void> createNewFeedback(AdminFeedbackModel feedback) async {
    final entryWithId = AdminFeedbackModel(
      id: feedback.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: feedback.userId,
      userName: feedback.userName,
      userEmail: feedback.userEmail,
      category: feedback.category,
      type: feedback.type,
      message: feedback.message,
      ratingIndex: feedback.ratingIndex,
      timestamp: feedback.timestamp,
      status: feedback.status,
      device: feedback.device,
      appVersion: feedback.appVersion,
    );
    await _repository.addFeedback(entryWithId);
    await loadAllFeedback();
  }

  Future<void> updateFeedbackStatus(String? id, String status) async {
    if (id == null) return;
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      final updatedItem = _items[index].copyWith(status: status);
      await _repository.updateFeedback(updatedItem);
      if (selectedItem?.id == id) {
        selectedItem = updatedItem;
      }
      await loadAllFeedback();
    }
  }

  Future<void> updateItemScores(String id, double u, double f, double d, double p) async {
    await _repository.addScore(id, {
      "usability": u,
      "features": f,
      "design": d,
      "performance": p,
      "timestamp": DateTime.now().toIso8601String(),
    });
    await loadAllFeedback();
  }
}