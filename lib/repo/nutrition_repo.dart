import '../model/nutrition_entry_model.dart';

abstract class NutritionRepo {
  Future<void> saveEntry(NutritionEntryModel model);
  Future<NutritionEntryModel?> getEntry(String userId, String date);
  Future<List<NutritionEntryModel>> getAllEntries(String userId);
}
