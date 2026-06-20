import '../../model/onboarding_survey_data.dart';
import 'water_tracker_setup_service.dart';
import 'acne_tracker_setup_service.dart';
import 'period_tracker_setup_service.dart';
import 'dermatology_tracker_setup_service.dart';

class OnboardingTrackerInitializer {
  static Future<void> initializeAllTrackers({
    required String userId,
    required OnboardingSurveyData surveyData,
  }) async {
    await WaterTrackerSetupService.initializeWaterTrackerFromOnboarding(
      userId: userId,
      waterGoal: surveyData.waterGoal,
    );
    await AcneTrackerSetupService.initializeAcneTrackerFromOnboarding(
      userId: userId,
      skinType: surveyData.skinType,
      acneConcerns: surveyData.acneTypes,
      usesMedication: surveyData.usesMedication,
      medicationType: surveyData.medicationType,
      medicationTime: surveyData.medicationTime,
    );
    await PeriodTrackerSetupService.initializeCycleTrackerFromOnboarding(
      userId: userId,
      lastPeriodDate: surveyData.lastCycleDate,
    );
    await DermatologyTrackerSetupService.initializeDermatologyTrackerFromOnboarding(
      userId: userId,
      visitsDerma: surveyData.visitsDerma,
      lastVisitDate: surveyData.lastDermaVisit,
    );
  }
}
