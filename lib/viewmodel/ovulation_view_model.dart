import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/ovulation_log_model.dart';
import '../model/period_log_model.dart';
import '../model/cycle_analytics_engine.dart';
import '../repo/ovulation_repo.dart';
import '../repo/period_repo.dart';
import '../repo/period_repo_impl.dart';

class OvulationViewModel extends ChangeNotifier {
  final OvulationRepo _repo;
  final PeriodRepo _periodRepo;
  String _userId;

  OvulationViewModel({required OvulationRepo ovulationRepo, PeriodRepo? periodRepo, FirebaseAuth? auth})
      : _repo = ovulationRepo,
        _periodRepo = periodRepo ?? PeriodRepoImpl(),
        _userId = (auth ?? FirebaseAuth.instance).currentUser?.uid ?? 'guest' {
    if (_userId != 'guest') {
      fetchLogs();
    }
  }

  String get userId => _userId;

  void setUserId(String id) {
    if (_userId != id) {
      _userId = id;
      fetchLogs();
    }
  }

  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  List<OvulationLogModel> _logs = [];
  List<PeriodLogModel> _periodLogs = [];
  CycleAnalyticsResult? _analyticsResult;

  DateTime get currentMonth => _currentMonth;
  DateTime get selectedDate => _selectedDate;
  List<OvulationLogModel> get logs => _logs;
  List<PeriodLogModel> get periodLogs => _periodLogs;
  CycleAnalyticsResult? get analyticsResult => _analyticsResult;

  // Compatibility helper
  bool get isPeriodTracker => false;

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
    _periodLogs = await _periodRepo.getLogsForUser(_userId);
    _analyticsResult = CycleAnalyticsEngine.calculate(
      periodLogs: _periodLogs,
      ovulationLogs: _logs,
    );
    notifyListeners();
  }

  void changeMonth(int increment) {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + increment);
    notifyListeners();
  }

  void setCurrentMonth(DateTime date) {
    _currentMonth = DateTime(date.year, date.month, date.day);
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

  Future<void> logOvulationRange(DateTime ovulationDate) async {
    final now = DateTime.now();

    // Log ovulation day
    await _updateOrAddLogForDate(ovulationDate, (l) => l.copyWith(isOvulationDay: true, isFertileWindow: true));

    // Log 3 days before
    for (int i = 1; i <= 3; i++) {
      final date = ovulationDate.subtract(Duration(days: i));
      await _updateOrAddLogForDate(date, (l) => l.copyWith(isFertileWindow: true));
    }

    // Log 2 days after
    for (int i = 1; i <= 2; i++) {
      final date = ovulationDate.add(Duration(days: i));
      await _updateOrAddLogForDate(date, (l) => l.copyWith(isFertileWindow: true));
    }

    await fetchLogs();
  }

  Future<void> _updateOrAddLogForDate(DateTime date, OvulationLogModel Function(OvulationLogModel) updateFn) async {
    final existingLog = _getLogForDate(date);
    final now = DateTime.now();

    if (existingLog != null) {
      final updatedLog = updateFn(existingLog).copyWith(updatedAt: now);
      await _repo.updateLog(updatedLog);
    } else {
      final newLog = updateFn(OvulationLogModel(
        id: '',
        userId: _userId,
        date: date,
        createdAt: now,
        updatedAt: now,
      ));
      await _repo.addLog(newLog);
    }
  }

  OvulationLogModel? _getLogForDate(DateTime date) {
    try {
      return _logs.firstWhere((l) =>
      l.date.year == date.year &&
          l.date.month == date.month &&
          l.date.day == date.day
      );
    } catch (e) {
      return null;
    }
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
    }
    await fetchLogs();
  }
}
