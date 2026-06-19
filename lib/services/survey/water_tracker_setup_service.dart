import 'package:cloud_firestore/cloud_firestore.dart';

class WaterTrackerSetupService {
  static Future<void> initializeWaterTrackerFromOnboarding({
    required String userId,
    required double? waterGoal,
  }) async {
    // ONBOARDING INITIALIZATION
    final now = DateTime.now();
    final todayStr = DateTime(now.year, now.month, now.day).toIso8601String().split('T')[0];
    
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'waterGoal': waterGoal ?? 2.0,
      'water_logs': {
        todayStr: 0.0,
      }
    }, SetOptions(merge: true));
  }
}
