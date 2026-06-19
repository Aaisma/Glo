import 'package:cloud_firestore/cloud_firestore.dart';

class AcneTrackerSetupService {
  static Future<void> initializeAcneTrackerFromOnboarding({
    required String userId,
    required String? skinType,
    required List<String> acneConcerns,
    required bool usesMedication,
    required String? medicationType,
    required String? medicationTime,
  }) async {
    // ONBOARDING INITIALIZATION
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'skinType': skinType ?? "Normal",
      'acneTypes': acneConcerns,
      'usesMedication': usesMedication,
      'medicationType': medicationType,
      'medicationTime': medicationTime,
    }, SetOptions(merge: true));
  }
}
