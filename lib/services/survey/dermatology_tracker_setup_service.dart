import 'package:cloud_firestore/cloud_firestore.dart';

class DermatologyTrackerSetupService {
  static Future<void> initializeDermatologyTrackerFromOnboarding({
    required String userId,
    required bool visitsDerma,
    required DateTime? lastVisitDate,
  }) async {
    // ONBOARDING INITIALIZATION
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'visitsDerma': visitsDerma,
      'lastDermaVisit': lastVisitDate?.toIso8601String(),
    }, SetOptions(merge: true));
  }
}
