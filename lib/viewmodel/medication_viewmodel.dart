import 'dart:async';

import 'package:flutter/material.dart';

import '../model/medication_model.dart';
import '../repo/medication_repo.dart';
import '../repo/medication_repo_impl.dart';

class MedicationViewModel extends ChangeNotifier {
  MedicationViewModel({
    MedicationRepo? repo,
  }) : _repo = repo ?? MedicationRepoImpl();

  final MedicationRepo _repo;

  List<MedicationModel> _medications = [];
  bool _loading = false;
  String? _error;

  StreamSubscription<List<MedicationModel>>? _medicationSubscription;

  List<MedicationModel> get medications => _medications;
  bool get loading => _loading;
  String? get error => _error;

  Future<bool> addMedication(
      MedicationModel medication,
      String userId,
      ) async {
    return _run(() async {
      _validateUserId(userId);

      medication.userId = userId;

      await _repo.addMedication(medication, userId);

      return true;
    });
  }

  Future<bool> updateMedication(
      MedicationModel medication,
      String userId,
      ) async {
    return _run(() async {
      _validateUserId(userId);

      medication.userId = userId;

      await _repo.updateMedication(medication, userId);

      return true;
    });
  }

  Future<bool> deleteMedication(
      String userId,
      String medicationId,
      ) async {
    return _run(() async {
      _validateUserId(userId);

      await _repo.deleteMedication(medicationId);

      return true;
    });
  }

  Future<bool> fetchMedications(String userId) async {
    return _run(() async {
      _validateUserId(userId);

      _medications = await _repo.getMedications(userId);

      return true;
    });
  }

  Stream<List<MedicationModel>> fetchMedicationsStream(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.error(Exception("User ID is required."));
    }

    return _repo.getMedicationsStream(userId);
  }

  void listenToMedications(String userId) {
    _medicationSubscription?.cancel();

    if (userId.trim().isEmpty) {
      _error = "User ID is required.";
      _loading = false;
      notifyListeners();
      return;
    }

    _setLoading(true);

    _medicationSubscription = _repo.getMedicationsStream(userId).listen(
          (medications) {
        _medications = medications;
        _error = null;
        _loading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }

  Stream<int> getMedicationCountStream(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.error(Exception("User ID is required."));
    }

    return _repo.getMedicationCountStream(userId);
  }

  Stream<int> getAllMedicationCountStream() {
    return _repo.getAllMedicationCountStream();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<bool> Function() action) async {
    try {
      _setLoading(true);
      _error = null;

      final result = await action();

      return result;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw Exception("User ID is required.");
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _medicationSubscription?.cancel();
    super.dispose();
  }
}