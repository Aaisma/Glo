import 'package:flutter/foundation.dart';
import 'package:glo/model/feedback_model.dart';
import 'package:glo/repo/feedback_repo.dart';

enum FeedbackState { initial, loading, success, error }

class FeedbackViewModel extends ChangeNotifier {
  final FeedbackRepo _repository;

  FeedbackViewModel({required FeedbackRepo repository}) : _repository = repository;

  // Form fields
  String _selectedCategory = '';
  String _selectedType = '';
  String _userMessage = '';
  int _selectedRatingIndex = -1;

  // State
  FeedbackState _state = FeedbackState.initial;
  String _errorMessage = '';
  List<FeedbackModel> _history = [];

  // Getters
  FeedbackState get state => _state;
  String get errorMessage => _errorMessage;
  List<FeedbackModel> get history => _history;

  String get selectedCategory => _selectedCategory;
  String get selectedType => _selectedType;
  String get userMessage => _userMessage;
  int get selectedRatingIndex => _selectedRatingIndex;

  // Update form fields
  void updateCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void updateMessage(String message) {
    _userMessage = message;
    notifyListeners();
  }

  void updateRatingIndex(int index) {
    _selectedRatingIndex = index;
    notifyListeners();
  }

  // Submit feedback to Firestore
  Future<bool> sendFeedback() async {
    _state = FeedbackState.loading;
    notifyListeners();

    try {
      final feedbackPayload = FeedbackModel(
        category: _selectedCategory,
        type: _selectedType,
        message: _userMessage,
        ratingIndex: _selectedRatingIndex,
        timestamp: DateTime.now(), status: '',
      );

      await _repository.submitFeedback(feedbackPayload);

      _state = FeedbackState.success;
      _clearForm();
      notifyListeners();
      return true;
    } catch (e, stack) {
      _state = FeedbackState.error;
      _errorMessage = e.toString();
      debugPrint("Firestore error: $e");
      debugPrintStack(stackTrace: stack);
      notifyListeners();
      return false;
    }
  }

  // Load feedback history from Firestore
  Future<void> loadFeedbackHistory() async {
    try {
      _history = await _repository.fetchFeedbackHistory();
      notifyListeners();
    } catch (e, stack) {
      _errorMessage = e.toString();
      debugPrint("Error loading feedback history: $e");
      debugPrintStack(stackTrace: stack);
      notifyListeners();
    }
  }

  // Reset form after submission
  void _clearForm() {
    _selectedCategory = '';
    _selectedType = '';
    _userMessage = '';
    _selectedRatingIndex = -1;
  }
}
