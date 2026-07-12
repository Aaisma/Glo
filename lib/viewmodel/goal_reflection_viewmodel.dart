import 'package:flutter/material.dart';
import '../repo/journal_repo.dart';

class GoalReflectionViewModel extends ChangeNotifier {
  final JournalRepo repository;
  bool? isGoalsCompleted = true;
  int productivityRating = 4;

  GoalReflectionViewModel({required this.repository});

  void setGoalsCompleted(bool? completed) {
    isGoalsCompleted = completed;
    notifyListeners();
  }

  void setProductivityRating(int rating) {
    productivityRating = rating;
    notifyListeners();
  }
}
