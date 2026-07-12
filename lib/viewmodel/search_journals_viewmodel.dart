import 'package:flutter/material.dart';
import 'package:glo/model/journal_entry_model.dart';
import 'package:glo/repo/journal_repo.dart';

class SearchJournalsViewModel extends ChangeNotifier {
  final JournalRepo repository;
  List<JournalEntryModel> _allJournals = [];
  List<JournalEntryModel> _filteredJournals = [];
  bool _isLoading = false;

  SearchJournalsViewModel({required this.repository});

  List<JournalEntryModel> get filteredJournals => _filteredJournals;
  bool get isLoading => _isLoading;

  void searchJournals(String userId, String query) {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) {
      _filteredJournals = List.from(_allJournals);
    } else {
      _filteredJournals = _allJournals.where((journal) {
        return journal.title.toLowerCase().contains(cleanQuery) || 
               journal.content.toLowerCase().contains(cleanQuery);
      }).toList();
    }
    notifyListeners();
  }

  void updateJournals(List<JournalEntryModel> journals) {
    _allJournals = journals;
    _filteredJournals = journals;
    notifyListeners();
  }
}
