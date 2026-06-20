import 'package:flutter/material.dart';
import '../model/history_model.dart';
import '../repo/history_repo.dart';

class HistoryViewModel extends ChangeNotifier {
  final HistoryRepo _repo = HistoryRepo();
  List<HistoryModel> _history = [];

  List<HistoryModel> get history => _history;

  void listenToHistory(String userId) {
    _repo.getUserHistory(userId).listen((data) {
      _history = data;
      notifyListeners();
    });
  }
}
