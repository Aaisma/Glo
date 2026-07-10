import '../../model/visit_model.dart';
import '../../model/onboarding_survey_data.dart';
import '../../repo/visit_repo_impl.dart';

class DermatologyTrackerSetupService {
  static Future<void> initialize(String userId, OnboardingSurveyData surveyData) async {
    final repo = VisitRepoImpl();

    if (surveyData.lastDermaVisit != null) {
      final visit = VisitModel(
        doctorName: "Dermatologist",
        visitDate: surveyData.lastDermaVisit,
        notes: "Initial visit recorded during onboarding survey.",
        followUpRequired: false,
      );

      await repo.addVisit(visit, userId);
    }
  }
}
