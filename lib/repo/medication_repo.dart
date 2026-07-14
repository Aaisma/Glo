import '../model/medication_model.dart';

/// Abstract repository defining medication operations.
/// Implemented by [MedicationRepoImpl].
abstract class MedicationRepo {
  /// Add a new medication for a given user.
  Future<void> addMedication(MedicationModel medication, String userId);

  /// Update an existing medication for a given user.
  Future<void> updateMedication(MedicationModel medication, String userId);

  /// Delete a medication by its ID.
  Future<void> deleteMedication(String medicationId);

  /// Fetch all medications for a given user.
  Future<List<MedicationModel>> getMedications(String userId);

  /// Stream medications for a given user (real-time updates).
  Stream<List<MedicationModel>> getMedicationsStream(String userId);

  /// Stream the count of medications for a given user.
  Stream<int> getMedicationCountStream(String userId);

  /// Stream the count of all medications across all users.
  Stream<int> getAllMedicationCountStream();
}
