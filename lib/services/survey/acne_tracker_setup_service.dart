import 'package:intl/intl.dart';
import '../../model/acne_tracker_model.dart';
import '../../model/onboarding_survey_data.dart';
import '../../repo/acne_repo_impl.dart';

class AcneTrackerSetupService {
  static Future<void> initialize(String userId, OnboardingSurveyData surveyData) async {
    final repo = AcneRepoImpl();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Create an initial entry based on survey data
    final model = AcneTrackerModel(
      userId: userId,
      date: today,
      severity: "Initial", // Placeholder severity
      checklist: surveyData.acneTypes,
      products: [],
      note: "Profile initialized from onboarding survey. Skin Type: ${surveyData.skinType ?? 'Unknown'}",
      imagePath: "",
    );

    await repo.saveEntry(model);
  }
}
