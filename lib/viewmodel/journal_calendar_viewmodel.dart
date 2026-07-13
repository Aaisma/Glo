import 'package:flutter/material.dart';
import '../repo/journal_repo.dart';

class JournalCalendarViewModel extends ChangeNotifier {
  final JournalRepo repository;
  int selectedDay = 10;

  JournalCalendarViewModel({required this.repository});

  void selectDay(int day) {
    selectedDay = day;
    notifyListeners();
  }
}
