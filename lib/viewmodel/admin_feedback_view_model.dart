import 'package:flutter/material.dart';
import 'package:glo/model/feedback_model.dart';
import 'package:glo/repo/feedback_repo.dart';
import 'package:glo/repo/feedback_repo_impl.dart';

class AdminFeedbackViewModel extends ChangeNotifier {
  final FeedbackRepo _repository = FeedbackRepoImpl();

  List<AdminFeedbackModel> _items = [];
  bool _isLoading = false;
  AdminFeedbackModel? selectedItem;

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
    _items = await _repository.getFeedback();
    _isLoading = false;
    notifyListeners();
  }

  void selectItem(AdminFeedbackModel item) {
    selectedItem = item;
    notifyListeners();
  }

  Future<void> createNewFeedback(AdminFeedbackModel feedback) async {
    final entryWithId = AdminFeedbackModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: feedback.userName,
      userEmail: feedback.userEmail,
      category: feedback.category,
      type: feedback.type,
      date: feedback.date,
      time: feedback.time,
      message: feedback.message,
      device: feedback.device,
      appVersion: feedback.appVersion,
      usability: feedback.usability,
      features: feedback.features,
      design: feedback.design,
      performance: feedback.performance,
      status: feedback.status,
    );
    await _repository.addFeedback(entryWithId);
    await loadAllFeedback();
  }

  Future<void> updateFeedbackStatus(String id, String status) async {
    await _repository.updateStatus(id, status);
    if (selectedItem?.id == id) selectedItem!.status = status;
    await loadAllFeedback();
  }

  Future<void> updateItemScores(String id, double u, double f, double d, double p) async {
    await _repository.updateScores(id, u, f, d, p);
    if (selectedItem?.id == id) {
      selectedItem = AdminFeedbackModel(
        id: selectedItem!.id,
        userName: selectedItem!.userName,
        userEmail: selectedItem!.userEmail,
        category: selectedItem!.category,
        type: selectedItem!.type,
        date: selectedItem!.date,
        time: selectedItem!.time,
        message: selectedItem!.message,
        device: selectedItem!.device,
        appVersion: selectedItem!.appVersion,
        usability: u,
        features: f,
        design: d,
        performance: p,
        status: selectedItem!.status,
      );
    }
    await loadAllFeedback();
  }
}