import 'package:flutter/material.dart';
import '../model/nutrition_entry_model.dart';
import '../repo/nutrition_repo.dart';

class NutritionTrackerViewModel extends ChangeNotifier {
  final NutritionRepo _repo;
  String? _userId;

  NutritionTrackerViewModel(this._repo);

  void updateUserId(String? newUserId) {
    if (_userId != newUserId) {
      _userId = newUserId;
      if (_userId != null) {
        loadToday(_userId!);
        loadHistory();
      } else {
        meals = [];
        history = [];
        notifyListeners();
      }
    }
  }

  String? get userId => _userId;

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> meals = [];
  String note = "";
  List<NutritionEntryModel> history = [];

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
      } else {
        meals = [];
        note = "";
      }
    } catch (e) {
      errorMessage = "Failed to load today's entry: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    if (_userId == null) return;
    try {
      history = await _repo.getAllEntries(_userId!);
      notifyListeners();
    } catch (e) {
      errorMessage = "Failed to load history: $e";
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
      final entry = NutritionEntryModel(
        userId: userId,
        date: _todayDate(),
        meals: meals,
        note: note,
      );
      await _repo.saveEntry(entry);
      await loadHistory();
    } catch (e) {
      errorMessage = "Failed to save entry: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
