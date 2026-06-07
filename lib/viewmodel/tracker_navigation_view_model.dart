import 'package:flutter/material.dart';
import '../model/tracker_theme.dart';

class TrackerNavigationViewModel extends ChangeNotifier {
  bool _isPeriodTracker = true;

  bool get isPeriodTracker => _isPeriodTracker;

  ThemeColors get currentTheme => _isPeriodTracker ? periodTheme : ovulationTheme;

  void toggleTracker(bool isPeriod) {
    if (_isPeriodTracker != isPeriod) {
      _isPeriodTracker = isPeriod;
      notifyListeners();
    }
  }
}
