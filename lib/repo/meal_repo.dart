import '../model/meal_entry_model.dart';

abstract class MealRepo {
  Future<void> saveEntry(MealEntryModel model);
  Future<MealEntryModel?> getEntry(String userId, String date);
  Future<List<MealEntryModel>> getAllEntries(String userId);
  Future<void> deleteEntry(String userId, String date);
}