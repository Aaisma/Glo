import 'package:flutter/material.dart';
import '../model/journal_model.dart';
import '../repo/journal_repo.dart';

class FutureLettersViewModel extends ChangeNotifier {
  final JournalRepo repository;
  bool isLockedSelected = true;

  FutureLettersViewModel({required this.repository});

  /// Returns a stream of journals filtered by the 'future_letter' category
  Stream<List<JournalModel>> getLettersStream(String userId) {
    return repository.getJournals(userId).map(
      (journals) => journals.where((j) => j.category == 'future_letter').toList(),
    );
  }

  void toggleTab(bool isLocked) {
    isLockedSelected = isLocked;
    notifyListeners();
  }
}
