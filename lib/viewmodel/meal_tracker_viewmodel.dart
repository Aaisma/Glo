import 'package:flutter/material.dart';
import '../model/meal_entry_model.dart';
import '../repo/meal_repo.dart';

class MealTrackerViewModel extends ChangeNotifier {
  final MealRepo _repo;

  MealTrackerViewModel(this._repo);

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> meals = [];
  String note = "";

  String _todayDate() => DateTime.now().toIso8601String().split("T")[0];

  Future<void> loadToday(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final entry = await _repo.getEntry(userId, _todayDate());
      if (entry != null) {
        meals = entry.meals;
        note = entry.note;
      }
    } catch (e) {
      errorMessage = "Failed to load today's entry: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void addMeal(String type, List<String> items, List<String> tags) {
    meals.add({"type": type, "items": items, "tags": tags});
    notifyListeners();
  }

  void removeMeal(int index) {
    meals.removeAt(index);
    notifyListeners();
  }

  void updateNote(String value) {
    note = value;
    notifyListeners();
  }

  Future<void> saveToday(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final entry = MealEntryModel(
        userId: userId,
        date: _todayDate(),
        meals: meals,
        note: note,
      );
      await _repo.saveEntry(entry);
    } catch (e) {
      errorMessage = "Failed to save entry: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}