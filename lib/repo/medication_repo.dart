import '../model/medication_model.dart';

abstract class MedicationRepo {
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