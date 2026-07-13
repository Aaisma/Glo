import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../model/period_log_model.dart';
import '../model/ovulation_log_model.dart';
import '../model/cycle_analytics_engine.dart';
import '../repo/period_repo.dart';
import '../repo/ovulation_repo.dart';
import '../repo/ovulation_repo_impl.dart';

class PeriodViewModel extends ChangeNotifier {
  final PeriodRepo _repo;
  final OvulationRepo _ovulationRepo;
  String _userId;

  PeriodViewModel({required PeriodRepo periodRepo, OvulationRepo? ovulationRepo})
      : _repo = periodRepo,
        _ovulationRepo = ovulationRepo ?? OvulationRepoImpl(),
        _userId = '' {}

  String get userId => _userId;

  void setUserId(String id) {
    if (_userId != id) {
      _userId = id;
      fetchLogs();
    }
  }

  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  List<PeriodLogModel> _logs = [];
  List<OvulationLogModel> _ovulationLogs = [];
  CycleAnalyticsResult? _analyticsResult;

  DateTime get currentMonth => _currentMonth;
  DateTime get selectedDate => _selectedDate;
  List<PeriodLogModel> get logs => _logs;
  List<OvulationLogModel> get ovulationLogs => _ovulationLogs;
  CycleAnalyticsResult? get analyticsResult => _analyticsResult;

  // Compatibility helpers
  DateTime? get lastPeriodStart => _analyticsResult?.lastPeriodStartDate;
  int? get cycleDay => _analyticsResult?.lastPeriodStartDate == null ? null : _analyticsResult?.currentCycleDay;
  String get predictionText => _analyticsResult?.nextPredictedEventText ?? "Log period to predict cycle";
  DateTime? get predictionDate => _analyticsResult?.nextPredictedEventDate;

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
    _ovulationLogs = await _ovulationRepo.getLogsForUser(_userId);
    _analyticsResult = CycleAnalyticsEngine.calculate(
      periodLogs: _logs,
      ovulationLogs: _ovulationLogs,
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

  Future<void> togglePeriodDay() async {
    await _updateOrAddLog((log) => log.copyWith(isPeriodDay: !log.isPeriodDay));
  }

  Future<void> logPeriodRange(DateTime startDate, int length) async {
    final now = DateTime.now();
    for (int i = 0; i < length; i++) {
      final date = startDate.add(Duration(days: i));
      PeriodLogModel? existingLog;
      try {
        existingLog = _logs.firstWhere((l) =>
        l.date.year == date.year &&
            l.date.month == date.month &&
            l.date.day == date.day
        );
      } catch (e) {
        existingLog = null;
      }

      if (existingLog != null) {
        if (!existingLog.isPeriodDay) {
          final updatedLog = existingLog.copyWith(isPeriodDay: true, updatedAt: now);
          await _repo.updateLog(updatedLog);
        }
      } else {
        final newLog = PeriodLogModel(
          id: '',
          userId: _userId,
          date: date,
          isPeriodDay: true,
          createdAt: now,
          updatedAt: now,
        );
        await _repo.addLog(newLog);
      }
    }
    await fetchLogs();
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

      final index = _logs.indexWhere((l) => l.id == updatedLog.id);
      if (index != -1) {
        _logs[index] = updatedLog;
      }
    } else {
      final newLog = updateFn(PeriodLogModel(
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
