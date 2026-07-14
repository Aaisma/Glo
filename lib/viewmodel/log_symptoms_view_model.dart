import 'package:flutter/material.dart';
import 'period_view_model.dart';
import 'ovulation_view_model.dart';

class LogSymptomsViewModel extends ChangeNotifier {
  final bool isPeriod;
  final PeriodViewModel? periodViewModel;
  final OvulationViewModel? ovulationViewModel;

  late Map<String, bool> _localSymptoms;
  late Map<String, bool> _initialSymptoms;

  String _note = "";
  String _initialNote = "";

  LogSymptomsViewModel({
    required this.isPeriod,
    this.periodViewModel,
    this.ovulationViewModel,
  }) {
    _initData();
  }

  void _initData() {
    if (isPeriod && periodViewModel != null) {
      _localSymptoms = Map.from(periodViewModel!.logForSelectedDate?.symptoms ?? {});
      _note = periodViewModel!.logForSelectedDate?.note ?? "";
    } else if (!isPeriod && ovulationViewModel != null) {
      _localSymptoms = Map.from(ovulationViewModel!.logForSelectedDate?.symptoms ?? {});
      _note = ovulationViewModel!.logForSelectedDate?.note ?? "";
    } else {
      _localSymptoms = {};
      _note = "";
    }
    _initialSymptoms = Map.from(_localSymptoms);
    _initialNote = _note;
  }

  DateTime get selectedDate => isPeriod ? periodViewModel!.selectedDate : ovulationViewModel!.selectedDate;

  String get note => _note;

  void updateNote(String newNote) {
    _note = newNote;
    notifyListeners();
  }

  bool get isSaved {
    if (_note != _initialNote) return false;
    for (var key in _localSymptoms.keys) {
      if (_localSymptoms[key] != (_initialSymptoms[key] ?? false)) return false;
    }
    for (var key in _initialSymptoms.keys) {
      if ((_localSymptoms[key] ?? false) != _initialSymptoms[key]) return false;
    }
    return true;
  }

  void handleOptionSelected(String option, String categoryTitle, List<dynamic> categoryOptions, bool isSingleChoice) {
    final key = "${categoryTitle}_$option";
    final noSymptomsKey = "${categoryTitle}_No Symptoms";

    if (option == "No Symptoms") {
      final isCurrentlySelected = _localSymptoms[key] ?? false;
      if (!isCurrentlySelected) {
        for (var catOption in categoryOptions) {
          _localSymptoms["${categoryTitle}_${catOption.label}"] = false;
        }
        _localSymptoms[key] = true;
      } else {
        _localSymptoms[key] = false;
      }
    } else {
      _localSymptoms[noSymptomsKey] = false;

      if (isSingleChoice) {
        for (var catOption in categoryOptions) {
          _localSymptoms["${categoryTitle}_${catOption.label}"] = false;
        }
        _localSymptoms[key] = true;
      } else {
        _localSymptoms[key] = !(_localSymptoms[key] ?? false);
      }
    }
    notifyListeners();
  }

  Set<String> getSelectedOptionsForCategory(String categoryTitle) {
    return _localSymptoms.entries
        .where((e) => e.value && e.key.startsWith("${categoryTitle}_"))
        .map((e) => e.key.replaceFirst("${categoryTitle}_", ""))
        .toSet();
  }

  void saveSymptoms() {
    if (isPeriod && periodViewModel != null) {
      for (var entry in _localSymptoms.entries) {
        if (entry.value != (periodViewModel!.logForSelectedDate?.symptoms[entry.key] ?? false)) {
          periodViewModel!.toggleSymptom(entry.key);
        }
      }
      if (_note != (periodViewModel!.logForSelectedDate?.note ?? "")) {
        periodViewModel!.saveNote(_note);
      }
    } else if (!isPeriod && ovulationViewModel != null) {
      for (var entry in _localSymptoms.entries) {
        if (entry.value != (ovulationViewModel!.logForSelectedDate?.symptoms[entry.key] ?? false)) {
          ovulationViewModel!.toggleSymptom(entry.key);
        }
      }
      if (_note != (ovulationViewModel!.logForSelectedDate?.note ?? "")) {
        ovulationViewModel!.saveNote(_note);
      }
    }
    // Update initials to match local so it shows as saved if they stay on page
    _initialSymptoms = Map.from(_localSymptoms);
    _initialNote = _note;
    notifyListeners();
  }
}
