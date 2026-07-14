import 'package:flutter/material.dart';

import 'package:glo/repo/journal_repo.dart';

import '../model/journal_model.dart';

class SearchJournalsViewModel extends ChangeNotifier {
  final JournalRepo repository;
  List<JournalModel> _allJournals = [];
  List<JournalModel> _filteredJournals = [];
  String _selectedFilter = 'All';
  bool _isLoading = false;

  SearchJournalsViewModel({required this.repository});

  List<JournalModel> get filteredJournals => _filteredJournals;
  bool get isLoading => _isLoading;

  void loadJournals(String userId) {
    _isLoading = true;
    notifyListeners();

    repository.getJournals(userId).listen((journals) {
      _allJournals = journals;
      _isLoading = false;
      _applyFilters('');
    });
  }

  void searchJournals(String userId, String query) {
    _applyFilters(query);
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    _applyFilters('');
  }

  void _applyFilters(String query) {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty && _selectedFilter == 'All') {
      _filteredJournals = List.from(_allJournals);
    } else {
      _filteredJournals = _allJournals.where((journal) {
        final titleMatch = journal.title.toLowerCase().contains(cleanQuery);
        final moodMatch = journal.mood.toLowerCase().contains(cleanQuery);
        final contentMatch = journal.content.toLowerCase().contains(cleanQuery);
        
        bool queryMatch = cleanQuery.isEmpty || titleMatch || moodMatch || contentMatch;

        if (_selectedFilter == 'Title') queryMatch = titleMatch;
        if (_selectedFilter == 'Mood') queryMatch = moodMatch;
        if (_selectedFilter == 'Content') queryMatch = contentMatch;
        
        return queryMatch;
      }).toList();
    }
    notifyListeners();
  }

  void updateJournals(List<JournalModel> journals) {
    _allJournals = journals;
    _filteredJournals = journals;
    notifyListeners();
  }
}
