import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../model/onboarding_survey_data.dart';
import '../../viewmodel/user_view_model.dart';
import '../../viewmodel/auth_view_model.dart';
import '../../viewmodel/period_view_model.dart';
import '../../constants/ayd_colour.dart';
import 'components/onboarding_widgets.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 11;

  // Local Controllers/State for step editing
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _feetController = TextEditingController();
  final _inchesController = TextEditingController();
  final _waterGoalController = TextEditingController();

  // Highlighted feature title on Feature Overview
  String? _selectedFeatureTitle = "Track Your Period";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userVM = Provider.of<UserViewModel>(context, listen: false);
      final restoredStep = await userVM.restoreOnboardingProgress();
      setState(() {
        _currentStep = restoredStep;
        _syncDataToControllers(userVM.surveyData);
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(restoredStep);
      }
    });

    _weightController.addListener(_updateBmi);
    _heightController.addListener(_updateBmi);
    _feetController.addListener(_updateBmi);
    _inchesController.addListener(_updateBmi);
    _ageController.addListener(() => setState(() {}));
    _waterGoalController.addListener(() => setState(() {}));
  }

  void _syncDataToControllers(OnboardingSurveyData data) {
    _ageController.text = data.actualAge?.toString() ?? '';
    _weightController.text = data.weight?.toString() ?? '';
    _heightController.text = data.height?.toString() ?? '';
    _feetController.text = data.feet?.toString() ?? '';
    _inchesController.text = data.inches?.toString() ?? '';
    _waterGoalController.text = data.waterGoal?.toString() ?? '';
  }

  void _updateBmi() {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    final data = userVM.surveyData;

    double? weight = double.tryParse(_weightController.text);
    double heightInMeters = 0;

    if (data.heightUnit == 'cm') {
      double? cm = double.tryParse(_heightController.text);
      if (cm != null) heightInMeters = cm / 100;
    } else {
      double? ft = double.tryParse(_feetController.text);
      double? inch = double.tryParse(_inchesController.text) ?? 0;
      if (ft != null) {
        heightInMeters = ((ft * 12) + inch) * 0.0254;
      }
    }

    if (weight != null && heightInMeters > 0) {
      final bmi = weight / (heightInMeters * heightInMeters);
      data.weight = weight;
      if (data.heightUnit == 'cm') {
        data.height = double.tryParse(_heightController.text);
      } else {
        data.feet = double.tryParse(_feetController.text);
        data.inches = double.tryParse(_inchesController.text);
      }
      data.bmi = bmi;
      if (bmi < 18.5) {
        data.bmiStatus = "Underweight";
        data.bmiTip = "Focus on nutrient-rich foods to fuel your glow! Healthy fats and proteins can support your energy and overall wellness.";
      } else if (bmi < 25) {
        data.bmiStatus = "Healthy Weight";
        data.bmiTip = "Great job maintaining a healthy BMI. Continue focusing on balanced nutrition, regular physical activity, hydration, and adequate sleep to support your overall wellness.";
      } else if (bmi < 30) {
        data.bmiStatus = "Overweight";
        data.bmiTip = "Small steps in movement can lead to big changes! Consider adding gentle, consistent activity to your daily routine.";
      } else {
        data.bmiStatus = "Obese";
        data.bmiTip = "Prioritize self-care by focusing on nourishing whole foods and gentle, regular activity. Consult with a healthcare provider for personalized guidance.";
      }
    } else {
      data.bmi = null;
      data.bmiStatus = null;
      data.bmiTip = null;
    }
    userVM.updateSurveyData(data);
  }

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      final userVM = Provider.of<UserViewModel>(context, listen: false);
      // Sync local controllers to data model before moving on
      if (_currentStep == 0) {
        userVM.surveyData.actualAge = int.tryParse(_ageController.text);
      } else if (_currentStep == 1) {
        userVM.surveyData.weight = double.tryParse(_weightController.text);
        userVM.surveyData.waterGoal = double.tryParse(_waterGoalController.text);
        if (userVM.surveyData.heightUnit == 'cm') {
          userVM.surveyData.height = double.tryParse(_heightController.text);
        } else {
          userVM.surveyData.feet = double.tryParse(_feetController.text);
          userVM.surveyData.inches = double.tryParse(_inchesController.text);
        }
      }
      
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      userVM.saveOnboardingProgress(_currentStep);
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      final userVM = Provider.of<UserViewModel>(context, listen: false);
      userVM.saveOnboardingProgress(_currentStep);
    }
  }

  Future<void> _finalizeRegistration() async {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    final periodVM = Provider.of<PeriodViewModel>(context, listen: false);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AydColors.primaryPink),
        ),
      );

      await userVM.finalizeOnboarding(periodVM: periodVM);

      if (mounted) {
        Navigator.pop(context); // Pop loading
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error completing onboarding: $e")),
        );
      }
    }
  }

  bool _isStepValid(OnboardingSurveyData data) {
    switch (_currentStep) {
      case 0:
        return data.ageGroup != null && _ageController.text.isNotEmpty;
      case 1:
        return data.bmi != null && _waterGoalController.text.isNotEmpty;
      case 2:
        return true; // BMI result page is informational
      case 3:
        return data.lastCycleDate != null;
      case 4:
        return data.skinType != null && data.goals.isNotEmpty;
      case 5:
        return data.acneTypes.isNotEmpty;
      case 6:
        return !data.usesMedication || (data.medicationType != null && data.medicationTime != null);
      case 7:
        return !data.visitsDerma || data.lastDermaVisit != null;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final data = userVM.surveyData;

    return Scaffold(
      backgroundColor: AydColors.accentLightPink,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (step) {
          setState(() => _currentStep = step);
        },
        children: [
          _buildStep1Age(data),
          _buildStep2Stats(data),
          _buildStep3Bmi(data),
          _buildStep4Cycle(data),
          _buildStep5Skin(data),
          _buildStep6Acne(data),
          _buildStep7Medication(data),
          _buildStep8Derma(data),
          _buildStep9WellnessSnapshot(data),
          _buildStep10ReviewAnswers(data),
          _buildStep11FeatureOverview(),
        ],
      ),
      bottomNavigationBar: _currentStep == 9
          ? null // Use sticky bottom in Review Profile screen
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  children: [
                    if (_currentStep > 0 && _currentStep < _totalSteps - 1) ...[
                      Expanded(
                        child: PrimaryActionButton(
                          text: "Back",
                          isSecondary: true,
                          onPressed: _prevPage,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: PrimaryActionButton(
                        text: _currentStep == _totalSteps - 1 ? "Start My Journey" : "Next",
                        onPressed: _isStepValid(data)
                            ? (_currentStep == _totalSteps - 1 ? _finalizeRegistration : _nextPage)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // STEP 1: Let's get to know you
  Widget _buildStep1Age(OnboardingSurveyData data) {
    return OnboardingPageScaffold(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      title: ". ݁₊ ⊹ . ݁˖ . ݁Let's get to know you. ݁₊ ⊹ . ݁˖ . ݁",
      subtitle: "Your answers help us personalize your skincare & wellness journey.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Which age group best describes you?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                OptionSelector(
                  options: const ['18 - 24', '25 - 34', '35 - 44', '45+'],
                  selectedOptions: data.ageGroup != null ? [data.ageGroup!] : [],
                  onSelected: (val) {
                    setState(() {
                      data.ageGroup = val;
                      _updateBmi();
                    });
                  },
                ),
              ],
            ),
          ),
          QuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("How old are you?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Age",
                    suffixText: "years",
                    filled: true,
                    fillColor: AydColors.accentLightPink.withValues(alpha: 0.3),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          const DynamicTipCard(
            title: "Tip for you",
            text: "Knowing your exact age helps provide more personalized wellness insights.",
            icon: Image(image: AssetImage("assets/images/survey/tips/girl_skincare.png"), width: 40, height: 40),
          ),
        ],
      ),
    );
  }

  // STEP 2: Body Basics
  Widget _buildStep2Stats(OnboardingSurveyData data) {
    return OnboardingPageScaffold(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      onBack: _prevPage,
      title: ". ݁₊ ⊹ . ݁˖ . ݁Your Body Basics. ݁₊ ⊹ . ݁˖ . ݁",
      subtitle: "Helps us give you better insights and recommendations.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("What is your current weight?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Weight",
                          filled: true,
                          fillColor: AydColors.accentLightPink.withValues(alpha: 0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                      child: const Text("kg", style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ],
            ),
          ),
          QuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("What is your height?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text("cm"),
                          selected: data.heightUnit == 'cm',
                          onSelected: (val) {
                            setState(() {
                              data.heightUnit = 'cm';
                              _updateBmi();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("ft + in"),
                          selected: data.heightUnit == 'ft',
                          onSelected: (val) {
                            setState(() {
                              data.heightUnit = 'ft';
                              _updateBmi();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (data.heightUnit == 'cm')
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Height in cm",
                      filled: true,
                      fillColor: AydColors.accentLightPink.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _feetController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Feet",
                            filled: true,
                            fillColor: AydColors.accentLightPink.withValues(alpha: 0.3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _inchesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Inches",
                            filled: true,
                            fillColor: AydColors.accentLightPink.withValues(alpha: 0.3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (data.bmi != null)
            DynamicTipCard(
              title: "BMI Tip",
              text: data.bmiTip ?? "",
              icon: const Image(image: AssetImage("assets/images/survey/tips/heart_character.png"), width: 40, height: 40),
            ),
          QuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("How much water do you aim to drink daily?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _waterGoalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Water Goal",
                          filled: true,
                          fillColor: AydColors.appBackground.withValues(alpha: 0.5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: AydColors.cardBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: AydColors.softSurface)),
                      child: const Text("Liters", style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ],
            ),
          ),
          const DynamicTipCard(
            title: "Hydration Tip",
            text: "Good hydration level. Maintain consistency throughout the day to keep your skin glowing.",
            icon: Image(image: AssetImage("assets/images/survey/tips/water_bottle.png"), width: 50, height: 50),
          ),
        ],
      ),
    );
  }

  // STEP 3: BMI Result
  Widget _buildStep3Bmi(OnboardingSurveyData data) {
    return OnboardingPageScaffold(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      onBack: _prevPage,
      title: ". ݁₊ ⊹ . ݁˖ . ݁Here's your BMI. ݁₊ ⊹ . ݁˖ . ݁",
      subtitle: "",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCard(
            child: Column(
              children: [
                const Image(image: AssetImage("assets/images/survey/tips/heart_character.png"), width: 50, height: 50),
                const SizedBox(height: 12),
                const Text("Here's your BMI", style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 8),
                Text(
                  data.bmi?.toStringAsFixed(1) ?? "--",
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AydColors.primaryPink),
                ),
                Text(
                  data.bmiStatus ?? "Unknown",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 16),
                // Dynamic Indicator
                _buildBmiIndicator(data.bmi),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Wellness Insight Card using AnimatedSwitcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: DynamicTipCard(
              key: ValueKey(data.bmiStatus ?? 'empty'),
              title: "Wellness Insight",
              text: data.bmiTip ?? "Please enter your height and weight in the previous step to get a personalized wellness insight card.",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiIndicator(double? bmi) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double relativePosition = 0.5;
        if (bmi != null) {
          // Map BMI 15 to 35 -> 0 to 1
          relativePosition = (bmi - 15) / (35 - 15);
          relativePosition = relativePosition.clamp(0.05, 0.95);
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            // Colored segments bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.green, Colors.orange, Colors.red],
                ),
              ),
            ),
            // Positioned indicator heart
            Positioned(
              left: (constraints.maxWidth - 24) * relativePosition,
              child: const Icon(Icons.favorite, color: AydColors.primaryPink, size: 24),
            ),
          ],
        );
      },
    );
  }

  // STEP 4: Let's track your cycle
  Widget _buildStep4Cycle(OnboardingSurveyData data) {
    return OnboardingPageScaffold(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      onBack: _prevPage,
      title: ". ݁₊ ⊹ . ݁˖ . ݁Let's track your cycle. ݁₊ ⊹ . ݁˖ . ݁",
      subtitle: "When did your last period start?",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("When did your last period start?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: data.lastCycleDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        data.lastCycleDate = date;
                      });
                      _updateBmi();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.lastCycleDate == null
                              ? "Select Date"
                              : DateFormat('MMMM dd, yyyy').format(data.lastCycleDate!),
                          style: TextStyle(
                            color: data.lastCycleDate == null ? Colors.black54 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.calendar_month, color: AydColors.primaryPink),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const DynamicTipCard(
            title: "Cycle Tip",
            text: "Tracking your cycle regularly helps improve period and ovulation predictions over time.",
            icon: Image(image: AssetImage("assets/images/survey/tips/cute_calender.png"), width: 40, height: 40),
          ),
          const SurveyNoteCard(
            text: "You can always edit your cycle information later from the Period & Ovulation Tracker in the app.",
          ),
        ],
      ),
    );
  }

  // STEP 5: Tell us about your skin
  Widget _buildStep5Skin(OnboardingSurveyData data) {
    return OnboardingPageScaffold(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      onBack: _prevPage,
      title: ". ݁₊ ⊹ . ݁˖ . ݁Tell us about your skin. ݁₊ ⊹ . ݁˖ . ݁",
      subtitle: "What is your skin type?",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("What is your skin type?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Column(
                  children: [
                    SurveyOptionTile(title: 'Normal', imagePath: 'assets/images/survey/skin_type/normal_skin.png', isSelected: data.skinType == 'Normal', onTap: () { setState(() { data.skinType = 'Normal'; }); _updateBmi(); }),
                    const SizedBox(height: 8),
                    SurveyOptionTile(title: 'Dry', imagePath: 'assets/images/survey/skin_type/dry_skin.png', isSelected: data.skinType == 'Dry', onTap: () { setState(() { data.skinType = 'Dry'; }); _updateBmi(); }),
                    const SizedBox(height: 8),
                    SurveyOptionTile(title: 'Oily', imagePath: 'assets/images/survey/skin_type/oily_skin.png', isSelected: data.skinType == 'Oily', onTap: () { setState(() { data.skinType = 'Oily'; }); _updateBmi(); }),
                    const SizedBox(height: 8),
                    SurveyOptionTile(title: 'Combination', imagePath: 'assets/images/survey/skin_type/combination_skin.png', isSelected: data.skinType == 'Combination', onTap: () { setState(() { data.skinType = 'Combination'; }); _updateBmi(); }),
                    const SizedBox(height: 8),
                    SurveyOptionTile(title: 'Sensitive', imagePath: 'assets/images/survey/skin_type/sensitive_skin.png', isSelected: data.skinType == 'Sensitive', onTap: () { setState(() { data.skinType = 'Sensitive'; }); _updateBmi(); }),
                  ],
                ),
              ],
            ),
          ),
          QuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("What are your skincare goals?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("(You can choose more than one)", style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 12),
                OptionSelector(
                  options: const ['Clear Skin', 'Hydration', 'Anti-aging', 'Brightening', 'Sun Protection'],
                  selectedOptions: data.goals,
                  multiSelect: true,
                  onSelected: (val) {
                    setState(() {
                      if (data.goals.contains(val)) {
                        data.goals.remove(val);
                      } else {
                        data.goals.add(val);
                      }
                    });
                    _updateBmi();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 6: Acne concerns
  Widget _buildStep6Acne(OnboardingSurveyData data) {
    return OnboardingPageScaffold(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      onBack: _prevPage,
      title: ". ݁₊ ⊹ . ݁˖ . ݁Your acne concerns. ݁₊ ⊹ . ݁˖ . ݁",
      subtitle: "Which types of acne do you usually experience? (Choose all that apply)",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Acne Concerns", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Column(
                  children: [
                    SurveyOptionTile(title: 'None', imagePath: 'assets/images/survey/acne_type/clear.png', isSelected: data.acneTypes.contains('None'), onTap: () { setState(() { data.acneTypes.clear(); data.acneTypes.add('None'); }); _updateBmi(); }),
                    const SizedBox(height: 8),
                    SurveyOptionTile(title: 'Whiteheads', imagePath: 'assets/images/survey/acne_type/whitehead.png', isSelected: data.acneTypes.contains('Whiteheads'), onTap: () { setState(() { data.acneTypes.remove('None'); if(data.acneTypes.contains('Whiteheads')) {
                      data.acneTypes.remove('Whiteheads');
                    } else {
                      data.acneTypes.add('Whiteheads');
                    } }); _updateBmi(); }),
                    const SizedBox(height: 8),
                    SurveyOptionTile(title: 'Blackheads', imagePath: 'assets/images/survey/acne_type/blackhead.png', isSelected: data.acneTypes.contains('Blackheads'), onTap: () { setState(() { data.acneTypes.remove('None'); if(data.acneTypes.contains('Blackheads')) {
                      data.acneTypes.remove('Blackheads');
                    } else {
                      data.acneTypes.add('Blackheads');
                    } }); _updateBmi(); }),
                    const SizedBox(height: 8),
                    SurveyOptionTile(title: 'Cystic', imagePath: 'assets/images/survey/acne_type/cystic.png', isSelected: data.acneTypes.contains('Cystic'), onTap: () { setState(() { data.acneTypes.remove('None'); if(data.acneTypes.contains('Cystic')) {
                      data.acneTypes.remove('Cystic');
                    } else {
                      data.acneTypes.add('Cystic');
                    } }); _updateBmi(); }),
                    const SizedBox(height: 8),
                    SurveyOptionTile(title: 'Pustules', imagePath: 'assets/images/survey/acne_type/pustules.png', isSelected: data.acneTypes.contains('Pustules'), onTap: () { setState(() { data.acneTypes.remove('None'); if(data.acneTypes.contains('Pustules')) {
                      data.acneTypes.remove('Pustules');
                    } else {
                      data.acneTypes.add('Pustules');
                    } }); _updateBmi(); }),
                    const SizedBox(height: 8),
                    SurveyOptionTile(title: 'Nodules', imagePath: 'assets/images/survey/acne_type/nodules.png', isSelected: data.acneTypes.contains('Nodules'), onTap: () { setState(() { data.acneTypes.remove('None'); if(data.acneTypes.contains('Nodules')) {
                      data.acneTypes.remove('Nodules');
                    } else {
                      data.acneTypes.add('Nodules');
                    } }); _updateBmi(); }),
                    const SizedBox(height: 8),
                    SurveyOptionTile(title: 'Not Sure', imagePath: 'assets/images/survey/acne_type/not_sure.png', isSelected: data.acneTypes.contains('Not Sure'), onTap: () { setState(() { data.acneTypes.remove('None'); if(data.acneTypes.contains('Not Sure')) {
                      data.acneTypes.remove('Not Sure');
                    } else {
                      data.acneTypes.add('Not Sure');
                    } }); _updateBmi(); }),
                  ],
                ),
              ],
            ),
          ),
          const DynamicTipCard(
            title: "Tip for you",
            text: "Whiteheads & blackheads can be managed with gentle cleansing and BHA (salicylic acid) products.",
            icon: Image(image: AssetImage("assets/images/survey/tips/cream_tube.png"), width: 40, height: 40),
          ),
        ],
      ),
    );
  }

  // STEP 7: About your treatments
  Widget _buildStep7Medication(OnboardingSurveyData data) {
    return OnboardingPageScaffold(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      onBack: _prevPage,
      title: ". ݁₊ ⊹ . ݁˖ . ݁About your treatments. ݁₊ ⊹ . ݁˖ . ݁",
      subtitle: "Are you currently using any acne treatments?",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Are you currently using any acne treatments?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("No"),
                        selected: !data.usesMedication,
                        onSelected: (val) {
                          setState(() {
                            data.usesMedication = false;
                            data.medicationType = null;
                            data.medicationTime = null;
                          });
                          _updateBmi();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Yes"),
                        selected: data.usesMedication,
                        onSelected: (val) {
                          setState(() {
                            data.usesMedication = true;
                          });
                          _updateBmi();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (data.usesMedication) ...[
            QuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("What type of treatment?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  OptionSelector(
                    options: const ['Oral', 'Topical', 'Both'],
                    selectedOptions: data.medicationType != null ? [data.medicationType!] : [],
                    onSelected: (val) {
                      setState(() {
                        data.medicationType = val;
                      });
                      _updateBmi();
                    },
                  ),
                ],
              ),
            ),
            QuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("When do you apply/take it?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  OptionSelector(
                    options: const ['Morning', 'Evening', 'Both'],
                    selectedOptions: data.medicationTime != null ? [data.medicationTime!] : [],
                    onSelected: (val) {
                      setState(() {
                        data.medicationTime = val;
                      });
                      _updateBmi();
                    },
                  ),
                ],
              ),
            ),
          ],
          const DynamicTipCard(
            title: "Tip",
            text: "Apply consistently and avoid excessive use to minimize irritation.",
            icon: Image(image: AssetImage("assets/images/survey/tips/moon_cloud.png"), width: 40, height: 40),
          ),
        ],
      ),
    );
  }

  // STEP 8: Dermatology Care
  Widget _buildStep8Derma(OnboardingSurveyData data) {
    return OnboardingPageScaffold(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      onBack: _prevPage,
      title: ". ݁₊ ⊹ . ݁˖ . ݁Dermatology care. ݁₊ ⊹ . ݁˖ . ݁",
      subtitle: "Do you visit a dermatologist for expert care?",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Do you visit a dermatologist?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("No"),
                        selected: !data.visitsDerma,
                        onSelected: (val) {
                          setState(() {
                            data.visitsDerma = false;
                            data.lastDermaVisit = null;
                          });
                          _updateBmi();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Yes"),
                        selected: data.visitsDerma,
                        onSelected: (val) {
                          setState(() {
                            data.visitsDerma = true;
                          });
                          _updateBmi();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (data.visitsDerma)
            QuestionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("When was your last visit?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: data.lastDermaVisit ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          data.lastDermaVisit = date;
                        });
                        _updateBmi();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data.lastDermaVisit == null
                                ? "Select Date"
                                : DateFormat('MMMM dd, yyyy').format(data.lastDermaVisit!),
                            style: TextStyle(
                              color: data.lastDermaVisit == null ? Colors.black54 : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(Icons.calendar_month, color: AydColors.primaryPink),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const DynamicTipCard(
            title: "Tip",
            text: "Regular follow-ups help monitor progress and adjust treatment plans.",
            icon: Image(image: AssetImage("assets/images/survey/tips/doctor_female.png"), width: 40, height: 40),
          ),
        ],
      ),
    );
  }

  // STEP 9: Wellness Snapshot Page
  Widget _buildStep9WellnessSnapshot(OnboardingSurveyData data) {
    return OnboardingPageScaffold(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      onBack: _prevPage,
      title: ". ݁₊ ⊹ . ݁˖ . ݁All set, Lovely!. ݁₊ ⊹ . ݁˖ . ݁",
      subtitle: "Here's your personalized wellness snapshot.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Illustration Image
          const Center(
            child: Image(
              image: AssetImage("assets/images/survey/happy_girl.png"),
              height: 160,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          // Single-Column list of Wellness Cards
          Column(
            children: [
              _buildSnapshotCard("‧₊˚❀༉‧₊˚.Cycle Tracking", data.lastCycleDate != null ? "Enabled" : "Not Enabled", true),
              const SizedBox(height: 12),
              _buildSnapshotCard("₊˚.𓆝༄.°.Water Goal", "${data.waterGoal ?? 2.0} Liters Daily", true),
              const SizedBox(height: 12),
              _buildSnapshotCard("₊˚ ༘⋆༄.°⋆BMI Status", "${data.bmi?.toStringAsFixed(1) ?? '--'} - ${data.bmiStatus ?? 'Normal'}", true),
              const SizedBox(height: 12),
              _buildSnapshotCard("₊˚✴⋆︎˚⋆.Skin Type", "${data.skinType ?? 'Normal'} Skin", true),
              const SizedBox(height: 12),
              _buildSnapshotCard("₊˚♡౨‧｡⋆.Acne Concerns", data.acneTypes.join(", "), data.acneTypes.isNotEmpty && !data.acneTypes.contains("None")),
              const SizedBox(height: 12),
              _buildSnapshotCard("₊˚˖𓂃☘︎₊˚.Treatment", data.usesMedication ? "${data.medicationType ?? 'Topical'} (${data.medicationTime ?? 'Evening'})" : "No Treatment", data.usesMedication),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotCard(String title, String status, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Visual status badge dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  status,
                  style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 10: Review answers page (New screen with sticky bottom CTA)
  Widget _buildStep10ReviewAnswers(OnboardingSurveyData data) {
    return Scaffold(
      backgroundColor: AydColors.accentLightPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 20),
          onPressed: _prevPage,
        ),
        title: Text(
          "${_currentStep + 1} of $_totalSteps",
          style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top progress indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _totalSteps,
                      backgroundColor: Colors.white,
                      color: AydColors.primaryPink,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${((_currentStep + 1) / _totalSteps * 100).round()}% Complete",
                    style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  Text(". ݁₊ ⊹ . ݁˖ .Review Your Profile. ݁₊ ⊹ . ݁˖ .", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 4),
                  Text("Check your information before completing setup. You can edit any section.", style: TextStyle(color: AydColors.primaryPink, fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                children: [
                  // Personal Info Card
                  ReviewAnswerSection(
                    icon: "⏱༄⚘.",
                    title: "Personal Information",
                    onEdit: () => _editPersonalSection(data),
                    fields: [
                      _buildReviewField("Age Group", data.ageGroup ?? "Not specified"),
                      _buildReviewField("Age", "${data.actualAge ?? '--'} years"),
                    ],
                  ),
                  // Body Basics Card
                  ReviewAnswerSection(
                    icon: "₊˚.𓆝༄.°",
                    title: "Body Basics",
                    onEdit: () => _editBodyBasicsSection(data),
                    fields: [
                      _buildReviewField("Weight", "${data.weight ?? '--'} kg"),
                      _buildReviewField("Height", data.heightUnit == 'cm' ? "${data.height ?? '--'} cm" : "${data.feet ?? '--'} ft ${data.inches ?? '--'} in"),
                      _buildReviewField("BMI", data.bmi?.toStringAsFixed(1) ?? '--'),
                      _buildReviewField("Category", data.bmiStatus ?? 'Unknown'),
                      _buildReviewField("Water Goal", "${data.waterGoal ?? '--'} Liters"),
                    ],
                  ),
                  // Cycle Tracking Card
                  ReviewAnswerSection(
                    icon: "‧₊˚❀༉‧₊˚.",
                    title: "Cycle Tracking",
                    onEdit: () => _editCycleSection(data),
                    fields: [
                      _buildReviewField("Last Period", data.lastCycleDate == null ? "Not specified" : DateFormat('MMMM dd, yyyy').format(data.lastCycleDate!)),
                    ],
                  ),
                  // Skin Profile Card
                  ReviewAnswerSection(
                    icon: "₊˚✴⋆︎˚⋆.",
                    title: "Skin Profile",
                    onEdit: () => _editSkinProfileSection(data),
                    fields: [
                      _buildReviewField("Skin Type", data.skinType ?? "Not specified"),
                      _buildReviewField("Goals", data.goals.isEmpty ? "None" : data.goals.join(", ")),
                    ],
                  ),
                  // Acne Concerns Card
                  ReviewAnswerSection(
                    icon: "₊˚ ༘⋆༄.°⋆",
                    title: "Acne Concerns",
                    onEdit: () => _editAcneSection(data),
                    fields: [
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: data.acneTypes.map((c) => Chip(
                          label: Text(c, style: const TextStyle(fontSize: 11, color: AydColors.primaryPink)),
                          backgroundColor: AydColors.primaryPink.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        )).toList(),
                      ),
                    ],
                  ),
                  // Treatments Card
                  ReviewAnswerSection(
                    icon: "₊˚˖𓂃☘︎₊˚.",
                    title: "Treatments",
                    onEdit: () => _editTreatmentsSection(data),
                    fields: [
                      _buildReviewField("Using Treatment", data.usesMedication ? "Yes" : "No"),
                      if (data.usesMedication) ...[
                        _buildReviewField("Type", data.medicationType ?? "Not specified"),
                        _buildReviewField("Schedule", data.medicationTime ?? "Not specified"),
                      ],
                    ],
                  ),
                  // Dermatology Card
                  ReviewAnswerSection(
                    icon: "₊˚ ༘⋆༄.°⋆",
                    title: "Dermatology",
                    onEdit: () => _editDermatologySection(data),
                    fields: [
                      _buildReviewField("Visits Dermatologist", data.visitsDerma ? "Yes" : "No"),
                      if (data.visitsDerma && data.lastDermaVisit != null)
                        _buildReviewField("Last Visit", DateFormat('MMMM dd, yyyy').format(data.lastDermaVisit!)),
                    ],
                  ),
                ],
              ),
            ),
            // Sticky Bottom CTA
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: PrimaryActionButton(
                  text: "Looks Good",
                  onPressed: _nextPage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  // BOTTOM SHEET INLINE EDITING FUNCTIONS
  void _editPersonalSection(OnboardingSurveyData data) {
    _ageController.text = data.actualAge?.toString() ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(". ݁₊ ⊹ . ݁˖ . ݁Edit Personal Info. ݁₊ ⊹ . ݁˖ . ݁", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AydColors.primaryPink)),
                  const SizedBox(height: 16),
                  const Text("Age Group", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  OptionSelector(
                    options: const ['18 - 24', '25 - 34', '35 - 44', '45+'],
                    selectedOptions: data.ageGroup != null ? [data.ageGroup!] : [],
                    onSelected: (val) {
                      setSheetState(() => data.ageGroup = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Age", suffixText: "years"),
                  ),
                  const SizedBox(height: 24),
                  PrimaryActionButton(
                    text: "Save Info",
                    onPressed: () {
                      setState(() {
                        data.actualAge = int.tryParse(_ageController.text);
                      });
                      Navigator.pop(context);
                      final userVM = Provider.of<UserViewModel>(context, listen: false);
                      userVM.saveOnboardingProgress(_currentStep);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editBodyBasicsSection(OnboardingSurveyData data) {
    _syncDataToControllers(data);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(". ݁₊ ⊹ . ݁˖ . ݁Edit Body Basics. ݁₊ ⊹ . ݁˖ . ݁", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AydColors.primaryPink)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Weight (kg)"),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Height Unit", style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text("cm"),
                            selected: data.heightUnit == 'cm',
                            onSelected: (val) {
                              setSheetState(() => data.heightUnit = 'cm');
                              _updateBmi();
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text("ft"),
                            selected: data.heightUnit == 'ft',
                            onSelected: (val) {
                              setSheetState(() => data.heightUnit = 'ft');
                              _updateBmi();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (data.heightUnit == 'cm')
                    TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Height (cm)"),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _feetController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Feet"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _inchesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Inches"),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _waterGoalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Water Goal (Liters)"),
                  ),
                  const SizedBox(height: 24),
                  PrimaryActionButton(
                    text: "Save Basics",
                    onPressed: () {
                      setState(() {
                        _updateBmi();
                        data.weight = double.tryParse(_weightController.text);
                        data.waterGoal = double.tryParse(_waterGoalController.text);
                        if (data.heightUnit == 'cm') {
                          data.height = double.tryParse(_heightController.text);
                        } else {
                          data.feet = double.tryParse(_feetController.text);
                          data.inches = double.tryParse(_inchesController.text);
                        }
                      });
                      Navigator.pop(context);
                      final userVM = Provider.of<UserViewModel>(context, listen: false);
                      userVM.saveOnboardingProgress(_currentStep);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editCycleSection(OnboardingSurveyData data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(". ݁₊ ⊹ . ݁˖ . ݁Edit Last Period Date. ݁₊ ⊹ . ݁˖ . ݁", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AydColors.primaryPink)),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: data.lastCycleDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setSheetState(() => data.lastCycleDate = date);
                        setState(() {});
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(data.lastCycleDate == null ? "Select Date" : DateFormat('MMMM dd, yyyy').format(data.lastCycleDate!)),
                          const Icon(Icons.calendar_month, color: AydColors.primaryPink),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryActionButton(
                    text: "Save Date",
                    onPressed: () {
                      Navigator.pop(context);
                      final userVM = Provider.of<UserViewModel>(context, listen: false);
                      userVM.saveOnboardingProgress(_currentStep);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editSkinProfileSection(OnboardingSurveyData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(". ݁₊ ⊹ . ݁˖ . ݁Edit Skin Profile. ݁₊ ⊹ . ݁˖ . ݁", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AydColors.primaryPink)),
                  const SizedBox(height: 16),
                  const Text("Skin Type", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OptionSelector(
                    options: const ['Normal', 'Dry', 'Oily', 'Combination', 'Sensitive'],
                    selectedOptions: data.skinType != null ? [data.skinType!] : [],
                    onSelected: (val) {
                      setSheetState(() => data.skinType = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Skincare Goals", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OptionSelector(
                    options: const ['Clear Skin', 'Hydration', 'Anti-aging', 'Brightening', 'Sun Protection'],
                    selectedOptions: data.goals,
                    multiSelect: true,
                    onSelected: (val) {
                      setSheetState(() {
                        if (data.goals.contains(val)) {
                          data.goals.remove(val);
                        } else {
                          data.goals.add(val);
                        }
                      });
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  PrimaryActionButton(
                    text: "Save Skin Profile",
                    onPressed: () {
                      Navigator.pop(context);
                      final userVM = Provider.of<UserViewModel>(context, listen: false);
                      userVM.saveOnboardingProgress(_currentStep);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editAcneSection(OnboardingSurveyData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(". ݁₊ ⊹ . ݁˖ . ݁Edit Acne Concerns. ݁₊ ⊹ . ݁˖ . ݁", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AydColors.primaryPink)),
                  const SizedBox(height: 16),
                  OptionSelector(
                    options: const ['None', 'Whiteheads', 'Blackheads', 'Cystic', 'Pustules', 'Nodules', 'Not Sure'],
                    selectedOptions: data.acneTypes,
                    multiSelect: true,
                    onSelected: (val) {
                      setSheetState(() {
                        if (val == 'None') {
                          data.acneTypes.clear();
                          data.acneTypes.add('None');
                        } else {
                          data.acneTypes.remove('None');
                          if (data.acneTypes.contains(val)) {
                            data.acneTypes.remove(val);
                          } else {
                            data.acneTypes.add(val);
                          }
                        }
                      });
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  PrimaryActionButton(
                    text: "Save Concerns",
                    onPressed: () {
                      Navigator.pop(context);
                      final userVM = Provider.of<UserViewModel>(context, listen: false);
                      userVM.saveOnboardingProgress(_currentStep);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editTreatmentsSection(OnboardingSurveyData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(". ݁₊ ⊹ . ݁˖ . ݁Edit Treatments. ݁₊ ⊹ . ݁˖ . ݁", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AydColors.primaryPink)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("No"),
                          selected: !data.usesMedication,
                          onSelected: (val) {
                            setSheetState(() {
                              data.usesMedication = false;
                              data.medicationType = null;
                              data.medicationTime = null;
                            });
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Yes"),
                          selected: data.usesMedication,
                          onSelected: (val) {
                            setSheetState(() => data.usesMedication = true);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  if (data.usesMedication) ...[
                    const SizedBox(height: 16),
                    const Text("Type of Treatment", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    OptionSelector(
                      options: const ['Oral', 'Topical', 'Both'],
                      selectedOptions: data.medicationType != null ? [data.medicationType!] : [],
                      onSelected: (val) {
                        setSheetState(() => data.medicationType = val);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("When do you apply/take it?", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    OptionSelector(
                      options: const ['Morning', 'Evening', 'Both'],
                      selectedOptions: data.medicationTime != null ? [data.medicationTime!] : [],
                      onSelected: (val) {
                        setSheetState(() => data.medicationTime = val);
                        setState(() {});
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryActionButton(
                    text: "Save Treatment",
                    onPressed: () {
                      Navigator.pop(context);
                      final userVM = Provider.of<UserViewModel>(context, listen: false);
                      userVM.saveOnboardingProgress(_currentStep);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editDermatologySection(OnboardingSurveyData data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(". ݁₊ ⊹ . ݁˖ . ݁Edit Dermatology Care. ݁₊ ⊹ . ݁˖ . ݁", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AydColors.primaryPink)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("No"),
                          selected: !data.visitsDerma,
                          onSelected: (val) {
                            setSheetState(() {
                              data.visitsDerma = false;
                              data.lastDermaVisit = null;
                            });
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text("Yes"),
                          selected: data.visitsDerma,
                          onSelected: (val) {
                            setSheetState(() => data.visitsDerma = true);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  if (data.visitsDerma) ...[
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: data.lastDermaVisit ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setSheetState(() => data.lastDermaVisit = date);
                          setState(() {});
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(data.lastDermaVisit == null ? "Select Date" : DateFormat('MMMM dd, yyyy').format(data.lastDermaVisit!)),
                            const Icon(Icons.calendar_month, color: AydColors.primaryPink),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryActionButton(
                    text: "Save Dermatology",
                    onPressed: () {
                      Navigator.pop(context);
                      final userVM = Provider.of<UserViewModel>(context, listen: false);
                      userVM.saveOnboardingProgress(_currentStep);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // STEP 11: Feature Overview (With 2-column Grid & Description display)
  Widget _buildStep11FeatureOverview() {
    final List<Map<String, String>> primaryFeatures = [
      {
        "title": "Track Your Period",
        "icon": "📅",
        "image": "assets/images/survey/last_page/period_tracking.png",
        "description": "Predict periods, fertile window, and ovulation."
      },
      {
        "title": "Track Acne",
        "icon": "❤️",
        "image": "assets/images/survey/last_page/acne_tracking.png",
        "description": "Monitor flare-ups, triggers, and progress."
      },
      {
        "title": "Track Skincare",
        "icon": "✨",
        "image": "assets/images/survey/last_page/skincare.png",
        "description": "Build routines and stay consistent."
      },
      {
        "title": "Track Mood",
        "icon": "😊",
        "image": "assets/images/survey/last_page/mood_tracking.png",
        "description": "Understand emotional patterns throughout your cycle."
      },
    ];

    final List<Map<String, String>> moreFeatures = [
      {
        "title": "Journal",
        "icon": "📖",
        "image": "assets/images/survey/last_page/journal.png",
        "description": "Capture thoughts, feelings and notes."
      },
      {
        "title": "Water Tracker",
        "icon": "💧",
        "image": "assets/images/survey/last_page/water_tracking.png",
        "description": "Stay hydrated daily."
      },
      {
        "title": "Dermatology Visits",
        "icon": "👩‍⚕️",
        "image": "assets/images/survey/last_page/derma_visit.png",
        "description": "Track appointments and recommendations."
      },
      {
        "title": "Ovulation Tracker",
        "icon": "🌼",
        "image": "assets/images/survey/last_page/ovulation.png",
        "description": "Monitor fertile days and cycle insights."
      },
    ];

    // Find currently selected feature description
    final allFeatures = [...primaryFeatures, ...moreFeatures];
    final selectedFeature = allFeatures.firstWhere((f) => f["title"] == _selectedFeatureTitle, orElse: () => allFeatures.first);

    return OnboardingPageScaffold(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      title: "You're one step closer\nto glowing inside out! ✨",
      subtitle: "Tap features to highlight and view detailed description.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary Features: 2-Column Grid Layout
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: primaryFeatures.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final item = primaryFeatures[index];
              final isSelected = _selectedFeatureTitle == item["title"];
              return FeatureLaunchCard(
                title: item["title"]!,
                icon: item["icon"]!,
                description: item["description"]!,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedFeatureTitle = item["title"];
                  });
                },
              );
            },
          ),
          const SizedBox(height: 20),
          // More Features Section Header
          const Text(
            "More Ways To Care For Yourself 🌸",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          // More Features: 2-Column Grid Layout
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moreFeatures.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final item = moreFeatures[index];
              final isSelected = _selectedFeatureTitle == item["title"];
              return FeatureLaunchCard(
                title: item["title"]!,
                icon: item["icon"]!,
                description: item["description"]!,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedFeatureTitle = item["title"];
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),
          // Feature Context Description Area
          DynamicTipCard(
            title: "${selectedFeature["icon"]} ${selectedFeature["title"]}",
            text: "${selectedFeature["description"]}\n\nThis tracker will be initialized automatically based on your survey answers once you complete setup.",
            icon: Image(image: AssetImage(selectedFeature["image"]!), width: 44, height: 44, errorBuilder: (_, __, ___) => const Icon(Icons.star, color: AydColors.primaryPink, size: 36)),
          ),
        ],
      ),
    );
  }
}
