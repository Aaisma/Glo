import 'package:flutter/material.dart';
import '../repo/journal_repo.dart';

class JournalHomeViewModel extends ChangeNotifier {
  final JournalRepo repository;
  String _selectedMood = '';

  JournalHomeViewModel({required this.repository});

  String get selectedMood => _selectedMood;

  void updateMood(String mood) {
    _selectedMood = mood;
    notifyListeners();
  }
}
