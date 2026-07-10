import '../../model/onboarding_survey_data.dart';
import 'period_tracker_setup_service.dart';
import 'water_tracker_setup_service.dart';
import 'acne_tracker_setup_service.dart';
import 'dermatology_tracker_setup_service.dart';

class OnboardingTrackerInitializer {
  /// Orchestrates the initialization of all trackers based on survey data.
  static Future<void> initializeAllTrackers({
    required String userId,
    required OnboardingSurveyData surveyData,
  }) async {
    // 1. Initialize Period Tracker if relevant data exists
    if (surveyData.lastCycleDate != null) {
      await PeriodTrackerSetupService.initialize(userId, surveyData.lastCycleDate!);
    }

    // 2. Initialize Water Tracker if goal is set
    if (surveyData.waterGoal != null && surveyData.waterGoal! > 0) {
      await WaterTrackerSetupService.initialize(userId, surveyData.waterGoal!);
    }

    // 3. Initialize Acne/Skin Tracker if acne types or skin goals are selected
    if (surveyData.acneTypes.isNotEmpty || surveyData.skinType != null) {
      await AcneTrackerSetupService.initialize(userId, surveyData);
    }

    // 4. Initialize Dermatology tracking if user visits a dermatologist
    if (surveyData.visitsDerma) {
      await DermatologyTrackerSetupService.initialize(userId, surveyData);
    }
  }
}
