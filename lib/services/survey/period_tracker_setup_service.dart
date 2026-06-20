import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/period_log_model.dart';

class PeriodTrackerSetupService {
  static Future<void> initializeCycleTrackerFromOnboarding({
    required String userId,
    required DateTime? lastPeriodDate,
  }) async {
    // ONBOARDING INITIALIZATION
    if (lastPeriodDate == null) return;
    
    final now = DateTime.now();
    for (int i = 0; i < 5; i++) {
      final date = lastPeriodDate.add(Duration(days: i));
      final docRef = FirebaseFirestore.instance.collection('period').doc();
      await docRef.set(PeriodLogModel(
        id: docRef.id,
        userId: userId,
        date: date,
        isPeriodDay: true,
        createdAt: now,
        updatedAt: now,
      ).toMap());
    }
  }
}
