import '../model/medication_model.dart';

abstract class MedicationRepo {
<<<<<<< HEAD
  Future<void> addMedication(MedicationModel med, String userId);

  // updated: include userId
  Future<void> updateMedication(MedicationModel med, String userId);

  // updated: include userId
  Future<void> deleteMedication(String userId, String id);

  Future<List<MedicationModel>> getMedications(String userId);

  // NEW: expose a stream for real-time updates
  Stream<List<MedicationModel>> getMedicationsStream(String userId);
}
=======
  Future<void> addMedication(
      MedicationModel medication,
      String userId,
      );

  Future<void> updateMedication(
      MedicationModel medication,
      String userId,
      );

  Future<void> deleteMedication(String medicationId);

  Future<List<MedicationModel>> getMedications(
      String userId,
      );

  Stream<List<MedicationModel>> getMedicationsStream(
      String userId,
      );

  Stream<int> getMedicationCountStream(
      String userId,
      );

  Stream<int> getAllMedicationCountStream();
}
>>>>>>> Ayusha_branch
