import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/period_log_model.dart';
import '../repo/period_repo.dart';

class PeriodViewModel extends ChangeNotifier {
  final PeriodRepo _repo;
  final String _userId;

  PeriodViewModel(this._repo) : _userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest' {
    fetchLogs();
  }

  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  List<PeriodLogModel> _logs = [];

  DateTime get currentMonth => _currentMonth;
  DateTime get selectedDate => _selectedDate;
  List<PeriodLogModel> get logs => _logs;

  PeriodLogModel? get logForSelectedDate {
    try {
      return _logs.firstWhere((log) => 
        log.date.year == _selectedDate.year &&
        log.date.month == _selectedDate.month &&
        log.date.day == _selectedDate.day
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchLogs() async {
    _logs = await _repo.getLogsForUser(_userId);
    notifyListeners();
  }

  void changeMonth(int increment) {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + increment);
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  Future<void> togglePeriodDay() async {
    await _updateOrAddLog((log) => log.copyWith(isPeriodDay: !log.isPeriodDay));
  }

  Future<void> updateBBT(double bbt) async {
    await _updateOrAddLog((log) => log.copyWith(bbt: bbt));
  }

  Future<void> updateFlow(String flow) async {
    await _updateOrAddLog((log) => log.copyWith(flow: flow));
  }

  Future<void> toggleSymptom(String symptom) async {
    await _updateOrAddLog((log) {
      final newSymptoms = Map<String, bool>.from(log.symptoms);
      newSymptoms[symptom] = !(newSymptoms[symptom] ?? false);
      return log.copyWith(symptoms: newSymptoms);
    });
  }

  Future<void> saveNote(String note) async {
    await _updateOrAddLog((log) => log.copyWith(note: note));
  }

  Future<void> _updateOrAddLog(PeriodLogModel Function(PeriodLogModel) updateFn) async {
    final existingLog = logForSelectedDate;
    final now = DateTime.now();

    if (existingLog != null) {
      final updatedLog = updateFn(existingLog).copyWith(updatedAt: now);
      await _repo.updateLog(updatedLog);
      
      // Update local state
      final index = _logs.indexWhere((l) => l.id == updatedLog.id);
      if (index != -1) {
        _logs[index] = updatedLog;
      }
    } else {
      final newLog = updateFn(PeriodLogModel(
        id: '', // Repo will set this
        userId: _userId,
        date: _selectedDate,
        createdAt: now,
        updatedAt: now,
      ));
      
      await _repo.addLog(newLog);
      // Re-fetch to get the new log with ID from DB
      await fetchLogs();
    }
    notifyListeners();
  }
}
