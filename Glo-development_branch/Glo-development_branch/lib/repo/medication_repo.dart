import '../model/medication_model.dart';

abstract class MedicationRepo {
  Future<void> addMedication(MedicationModel med, String userId);

  // updated: include userId
  Future<void> updateMedication(MedicationModel med, String userId);

  // updated: include userId
  Future<void> deleteMedication(String userId, String id);

  Future<List<MedicationModel>> getMedications(String userId);

  // NEW: expose a stream for real-time updates
  Stream<List<MedicationModel>> getMedicationsStream(String userId);
}
