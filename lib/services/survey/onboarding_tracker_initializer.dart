import 'package:flutter/foundation.dart';
import '../../model/onboarding_survey_data.dart';
import 'period_tracker_setup_service.dart';
import 'water_tracker_setup_service.dart';
import 'acne_tracker_setup_service.dart';
import 'dermatology_tracker_setup_service.dart';

class OnboardingTrackerInitializer {
  /// Orchestrates the initialization of all trackers based on survey data.
  ///
  /// Each tracker is isolated in its own try/catch: this runs AFTER
  /// updateSurvey() marks the account as onboarded, so a failure here must
  /// never propagate and undo that. One tracker failing (e.g. a Firestore
  /// permission error on the acne collection) should not stop the other
  /// three from initializing, and must never re-throw and block
  /// finalizeOnboarding() from completing.
  static Future<void> initializeAllTrackers({
    required String userId,
    required OnboardingSurveyData surveyData,
  }) async {
    // 1. Initialize Period Tracker if relevant data exists
    if (surveyData.lastCycleDate != null) {
      try {
        await PeriodTrackerSetupService.initialize(userId, surveyData.lastCycleDate!);
      } catch (e) {
        debugPrint('OnboardingTrackerInitializer: period tracker init failed: $e');
      }
    }

    // 2. Initialize Water Tracker if goal is set
    if (surveyData.waterGoal != null && surveyData.waterGoal! > 0) {
      try {
        await WaterTrackerSetupService.initialize(userId, surveyData.waterGoal!);
      } catch (e) {
        debugPrint('OnboardingTrackerInitializer: water tracker init failed: $e');
      }
    }

    // 3. Initialize Acne/Skin Tracker if acne types or skin goals are selected
    if (surveyData.acneTypes.isNotEmpty || surveyData.skinType != null) {
      try {
        await AcneTrackerSetupService.initialize(userId, surveyData);
      } catch (e) {
        debugPrint('OnboardingTrackerInitializer: acne tracker init failed: $e');
      }
    }

    // 4. Initialize Dermatology tracking if user visits a dermatologist
    if (surveyData.visitsDerma) {
      try {
        await DermatologyTrackerSetupService.initialize(userId, surveyData);
      } catch (e) {
        debugPrint('OnboardingTrackerInitializer: dermatology tracker init failed: $e');
      }
    }
  }
}