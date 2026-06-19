import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<void> saveMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedMood', mood);
  }

  Future<String?> getMood() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedMood');
  }
}
