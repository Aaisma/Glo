import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/nutrition_entry_model.dart';
import '../repo/nutrition_repo.dart';

class MealTrackerViewModel extends ChangeNotifier {
  final NutritionRepo _repo;

  MealTrackerViewModel(this._repo);

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> meals = [];
  String note = "";
  String? userId;
  List<NutritionEntryModel> history = [];

  String _todayDate() => DateTime.now().toIso8601String().split("T")[0];

  Future<void> ensureUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? "temp_user";
    if (userId != null) {
      await loadToday(userId!);
    }
  }

  Future<void> loadToday(String userId) async {
    this.userId = userId;
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
      history = await _repo.getAllEntries(userId);
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

  Future<void> saveToday([String? uid]) async {
    final targetUid = uid ?? userId;
    if (targetUid == null) {
      errorMessage = "User not logged in";
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final entry = NutritionEntryModel(
        userId: targetUid,
        date: _todayDate(),
        meals: meals,
        note: note,
      );
      await _repo.saveEntry(entry);
      history = await _repo.getAllEntries(targetUid);
    } catch (e) {
      errorMessage = "Failed to save entry: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

typedef NutritionTrackerViewModel = MealTrackerViewModel;