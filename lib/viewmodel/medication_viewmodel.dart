import 'package:flutter/material.dart';
import '../model/medication_model.dart';
import '../repo/medication_repo.dart';
import '../repo/medication_repo_impl.dart';

class MedicationViewModel extends ChangeNotifier {
  final MedicationRepo _repo = MedicationRepoImpl();

  List<MedicationModel> _medications = [];
  bool _loading = false;
  String? _error;

  List<MedicationModel> get medications => _medications;
  bool get loading => _loading;
  String? get error => _error;

  void _setMedications(List<MedicationModel> meds) {
    _medications = meds;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // 🔑 NEW: Stream method for real-time updates
  Stream<List<MedicationModel>> fetchMedicationsStream(String userId) {
    return _repo.getMedicationsStream(userId);
  }

  // Existing CRUD methods
  Future<void> addMedication(MedicationModel med, String userId) async {
    _setLoading(true);
    try {
      await _repo.addMedication(med, userId);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMedication(MedicationModel med, String userId) async {
    _setLoading(true);
    try {
      await _repo.updateMedication(med, userId);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteMedication(String userId, String id) async {
    _setLoading(true);
    try {
      await _repo.deleteMedication(userId, id);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMedications(String userId) async {
    _setLoading(true);
    try {
      final meds = await _repo.getMedications(userId);
      _setMedications(meds);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
