import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/ovulation_log_model.dart';
import '../repo/ovulation_repo.dart';

class OvulationViewModel extends ChangeNotifier {
  final OvulationRepo _repo;
  final String _userId;

  OvulationViewModel(this._repo) : _userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest' {
    fetchLogs();
  }

  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  List<OvulationLogModel> _logs = [];

  DateTime get currentMonth => _currentMonth;
  DateTime get selectedDate => _selectedDate;
  List<OvulationLogModel> get logs => _logs;

  OvulationLogModel? get logForSelectedDate {
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

  Future<void> toggleOvulationDay() async {
    await _updateOrAddLog((log) => log.copyWith(isOvulationDay: !log.isOvulationDay));
  }

  Future<void> toggleFertileWindow() async {
    await _updateOrAddLog((log) => log.copyWith(isFertileWindow: !log.isFertileWindow));
  }

  Future<void> updateBBT(double bbt) async {
    await _updateOrAddLog((log) => log.copyWith(bbt: bbt));
  }

  Future<void> updateSexDrive(String sexDrive) async {
    await _updateOrAddLog((log) => log.copyWith(sexDrive: sexDrive));
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

  Future<void> _updateOrAddLog(OvulationLogModel Function(OvulationLogModel) updateFn) async {
    final existingLog = logForSelectedDate;
    final now = DateTime.now();

    if (existingLog != null) {
      final updatedLog = updateFn(existingLog).copyWith(updatedAt: now);
      await _repo.updateLog(updatedLog);
      
      final index = _logs.indexWhere((l) => l.id == updatedLog.id);
      if (index != -1) {
        _logs[index] = updatedLog;
      }
    } else {
      final newLog = updateFn(OvulationLogModel(
        id: '',
        userId: _userId,
        date: _selectedDate,
        createdAt: now,
        updatedAt: now,
      ));
      
      await _repo.addLog(newLog);
      await fetchLogs();
    }
    notifyListeners();
  }
}
