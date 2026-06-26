import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/tracker_theme.dart';

class TrackerNavigationViewModel extends ChangeNotifier {
  bool _isPeriodTracker = true;
  bool _isNepaliCalendar = false;

  TrackerNavigationViewModel() {
    _loadPreferences();
  }

  bool get isPeriodTracker => _isPeriodTracker;
  bool get isNepaliCalendar => _isNepaliCalendar;

  ThemeColors get currentTheme => _isPeriodTracker ? periodTheme : ovulationTheme;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isNepaliCalendar = prefs.getBool('isNepaliCalendar') ?? false;
    notifyListeners();
  }

  void toggleTracker(bool isPeriod) {
    if (_isPeriodTracker != isPeriod) {
      _isPeriodTracker = isPeriod;
      notifyListeners();
    }
  }

  Future<void> toggleCalendarSystem() async {
    _isNepaliCalendar = !_isNepaliCalendar;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNepaliCalendar', _isNepaliCalendar);
  }
}
