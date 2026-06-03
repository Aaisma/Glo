import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_view_model.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;

  // Survey Data
  final _actualAgeController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _feetController = TextEditingController();
  final _inchesController = TextEditingController();
  final _waterGoalController = TextEditingController();
  DateTime? _lastCycleDate;

  String _heightUnit = 'cm'; // 'cm' or 'ft'
  double? _calculatedBMI;
  String? _bmiStatus;
  String? _bmiTip;

  String? _selectedAgeGroup;
  String? _selectedSkinType;
  final List<String> _selectedGoals = [];
  final List<String> _selectedAcneTypes = [];

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_calculateBMI);
    _heightController.addListener(_calculateBMI);
    _feetController.addListener(_calculateBMI);
    _inchesController.addListener(_calculateBMI);
  }

  void _calculateBMI() {
    double? weight = double.tryParse(_weightController.text);
    double heightInMeters = 0;

    if (_heightUnit == 'cm') {
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
      setState(() {
        _calculatedBMI = weight / (heightInMeters * heightInMeters);
        if (_calculatedBMI! < 18.5) {
          _bmiStatus = "Underweight";
          _bmiTip = "✨ Focus on nutrient-rich foods to fuel your glow!";
        } else if (_calculatedBMI! < 25) {
          _bmiStatus = "Normal";
          _bmiTip = "💖 You're in a healthy range! Keep up the great work.";
        } else if (_calculatedBMI! < 30) {
          _bmiStatus = "Overweight";
          _bmiTip = "🌸 Small steps in movement can lead to big changes!";
        } else {
          _bmiStatus = "Obese";
          _bmiTip = "💕 Prioritize balanced meals and consistent activity.";
        }
      });
    } else {
      setState(() {
        _calculatedBMI = null;
        _bmiStatus = null;
        _bmiTip = null;
      });
    }
  }

  bool _usesMedication = false;
  String? _medicationType; // Oral, Topical, Both
  String? _medicationTime; // AM, PM, Both

  bool _visitsDerma = false;
  DateTime? _lastDermaVisit;

  // Colors from Login/Register UI
  final Color primaryPink = const Color(0xFFFF3E63);
  final Color backgroundColor = const Color(0xFFFDECEF);

  // Options
  final List<String> _ageGroups = ['18-24', '25-34', '35-44', '45+'];
  final List<String> _skinTypes = ['Normal', 'Dry', 'Oily', 'Combination', 'Sensitive'];
  final List<String> _goals = ['Clear Skin', 'Hydration', 'Anti-aging', 'Brightening', 'Sun Protection'];
  final List<String> _acneTypes = ['Whitehead', 'Blackhead', 'Cystic', 'Pustules', 'Nodules'];
  final List<String> _medTypes = ['Oral', 'Topical', 'Both'];
  final List<String> _medTimes = ['AM', 'PM', 'Both'];


  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      setState(() => _currentStep++);
    } else {
      _submitSurvey();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitSurvey() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await userViewModel.updateSurvey(
          userId: user.uid,
          email: user.email ?? "",
          ageGroup: _selectedAgeGroup ?? "Not specified",
          skinType: _selectedSkinType ?? "Not specified",
          goals: _selectedGoals,
          actualAge: int.tryParse(_actualAgeController.text),
          bmi: _calculatedBMI,
          waterGoal: double.tryParse(_waterGoalController.text),
          lastCycleDate: _lastCycleDate,
          acneTypes: _selectedAcneTypes,
          usesMedication: _usesMedication,
          medicationType: _medicationType,
          medicationTime: _medicationTime,
          visitsDerma: _visitsDerma,
          lastDermaVisit: _lastDermaVisit,
        );
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error updating profile: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0 ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 20),
          onPressed: _prevPage,
        ) : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    "Glo Profile",
                    style: TextStyle(
                      color: primaryPink,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _totalSteps,
                      backgroundColor: Colors.white,
                      color: primaryPink,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1Age(),
                  _buildStep2Stats(),
                  _buildStep3Cycle(),
                  _buildStep4Skin(),
                  _buildStep5Acne(),
                  _buildStep6Medication(),
                  _buildStep7Derma(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPink,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isStepValid() ? _nextPage : null,
                      child: Text(
                        _currentStep == _totalSteps - 1 ? "Finish" : "Next",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryPink.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        try {
                          await context.read<UserViewModel>().createDefaultProfile();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error skipping survey: $e")),
                            );
                          }
                        }
                      },
                      child: Text(
                        "Skip Survey",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryPink),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isStepValid() {
    switch (_currentStep) {
      case 0: return _selectedAgeGroup != null && _actualAgeController.text.isNotEmpty;
      case 1: return _calculatedBMI != null && _waterGoalController.text.isNotEmpty;
      case 2: return _lastCycleDate != null;
      case 3: return _selectedSkinType != null && _selectedGoals.isNotEmpty;
      case 4: return _selectedAcneTypes.isNotEmpty;
      case 5: return !_usesMedication || (_medicationType != null && _medicationTime != null);
      case 6: return !_visitsDerma || _lastDermaVisit != null;
      default: return true;
    }
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: primaryPink),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: primaryPink, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep1Age() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Hey, Lovely!", "Let's start with some basics"),
          _buildTextField(controller: _actualAgeController, label: "Your Actual Age", icon: Icons.cake, keyboardType: TextInputType.number),
          const SizedBox(height: 24),
          const Text("Select Your Age Group", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: _selectedAgeGroup,
            onChanged: (val) => setState(() => _selectedAgeGroup = val),
            child: Column(
              children: _ageGroups.map((opt) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: RadioListTile<String>(
                  title: Text(opt, style: const TextStyle(fontSize: 14)),
                  value: opt,
                  activeColor: primaryPink,
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Stats() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Body & Glow", "Your health metrics matter!"),
          
          const Text("Weight (kg)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _weightController, 
            label: "Weight in kg", 
            icon: Icons.monitor_weight, 
            keyboardType: TextInputType.number
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Height", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ToggleButtons(
                isSelected: [_heightUnit == 'cm', _heightUnit == 'ft'],
                onPressed: (index) {
                  setState(() {
                    _heightUnit = index == 0 ? 'cm' : 'ft';
                    _calculateBMI();
                  });
                },
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: primaryPink,
                constraints: const BoxConstraints(minHeight: 30, minWidth: 45),
                children: const [
                  Text("cm", style: TextStyle(fontSize: 12)),
                  Text("ft", style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_heightUnit == 'cm')
            _buildTextField(
              controller: _heightController, 
              label: "Height in cm", 
              icon: Icons.height, 
              keyboardType: TextInputType.number
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _feetController, 
                    label: "Feet", 
                    icon: Icons.height, 
                    keyboardType: TextInputType.number
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _inchesController, 
                    label: "Inches", 
                    icon: Icons.height, 
                    keyboardType: TextInputType.number
                  ),
                ),
              ],
            ),
            
          if (_calculatedBMI != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primaryPink.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    "Your BMI: ${_calculatedBMI!.toStringAsFixed(1)}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryPink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Status: $_bmiStatus",
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _bmiTip!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Text("Daily Water Goal (Liters)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _waterGoalController, 
            label: "e.g. 2.5", 
            icon: Icons.water_drop, 
            keyboardType: TextInputType.number
          ),
          const SizedBox(height: 12),
          const Text("★ Tip: Staying hydrated keeps your skin glowing!", style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black54)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStep3Cycle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Cycle Tracker", "When was your last period started?"),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _lastCycleDate = date);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, color: primaryPink),
                  const SizedBox(width: 12),
                  Text(
                    _lastCycleDate == null ? "Select Date from Calendar" : DateFormat('MMMM dd, yyyy').format(_lastCycleDate!),
                    style: TextStyle(fontSize: 15, color: _lastCycleDate == null ? Colors.grey : Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Skin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Skin Profile", "Define your skin's unique needs"),
          const Text("What is your skin type?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skinTypes.map((type) {
              final isSelected = _selectedSkinType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedSkinType = type),
                selectedColor: primaryPink.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: isSelected ? primaryPink : Colors.black87),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text("Skincare Goals", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _goals.map((goal) {
              final isSelected = _selectedGoals.contains(goal);
              return FilterChip(
                label: Text(goal),
                selected: isSelected,
                onSelected: (val) => setState(() => val ? _selectedGoals.add(goal) : _selectedGoals.remove(goal)),
                selectedColor: primaryPink.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: isSelected ? primaryPink : Colors.black87),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5Acne() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Acne Concerns", "Which types of acne do you face?"),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _acneTypes.map((acne) {
              final isSelected = _selectedAcneTypes.contains(acne);
              return FilterChip(
                label: Text(acne),
                selected: isSelected,
                onSelected: (val) => setState(() => val ? _selectedAcneTypes.add(acne) : _selectedAcneTypes.remove(acne)),
                selectedColor: primaryPink.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: isSelected ? primaryPink : Colors.black87),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6Medication() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Medications", "Are you on any treatments?"),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: SwitchListTile(
              title: const Text("Using Medication?", style: TextStyle(fontSize: 15)),
              value: _usesMedication,
              onChanged: (val) => setState(() => _usesMedication = val),
              activeThumbColor: primaryPink,
            ),
          ),
          if (_usesMedication) ...[
            const SizedBox(height: 24),
            const Text("Type of Medication", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _medicationType,
              onChanged: (val) => setState(() => _medicationType = val),
              child: Row(
                children: _medTypes.map((t) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: RadioListTile<String>(
                      title: Text(t, style: const TextStyle(fontSize: 11)),
                      value: t,
                      contentPadding: EdgeInsets.zero,
                      activeColor: primaryPink,
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text("When do you use it?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _medicationTime,
              onChanged: (val) => setState(() => _medicationTime = val),
              child: Row(
                children: _medTimes.map((t) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: RadioListTile<String>(
                      title: Text(t, style: const TextStyle(fontSize: 11)),
                      value: t,
                      contentPadding: EdgeInsets.zero,
                      activeColor: primaryPink,
                    ),
                  ),
                )).toList(),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStep7Derma() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Dermatology", "Expert care check-in"),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: SwitchListTile(
              title: const Text("Do you visit a Dermatologist?", style: TextStyle(fontSize: 15)),
              value: _visitsDerma,
              onChanged: (val) => setState(() => _visitsDerma = val),
              activeThumbColor: primaryPink,
            ),
          ),
          if (_visitsDerma) ...[
            const SizedBox(height: 24),
            const Text("When was your last visit?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _lastDermaVisit = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: primaryPink),
                    const SizedBox(width: 12),
                    Text(
                      _lastDermaVisit == null ? "Select Date" : DateFormat('MMMM dd, yyyy').format(_lastDermaVisit!),
                      style: TextStyle(fontSize: 15, color: _lastDermaVisit == null ? Colors.grey : Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class RadioGroup<T> extends StatelessWidget {
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;

  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _RadioGroupScope<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: child,
    );
  }

  static _RadioGroupScope<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_RadioGroupScope<T>>();
  }
}

class _RadioGroupScope<T> extends InheritedWidget {
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  const _RadioGroupScope({
    required this.groupValue,
    required this.onChanged,
    required super.child,
  });

  @override
  bool updateShouldNotify(_RadioGroupScope<T> oldWidget) {
    return groupValue != oldWidget.groupValue || onChanged != oldWidget.onChanged;
  }
}
