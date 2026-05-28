import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../repo/user_repo_impl.dart';

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
  final _bmiController = TextEditingController();
  final _waterGoalController = TextEditingController();
  DateTime? _lastCycleDate;
  
  String? _selectedAgeGroup;
  String? _selectedSkinType;
  final List<String> _selectedGoals = [];
  final List<String> _selectedAcneTypes = [];
  
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

  final _userRepo = UserRepoImpl();

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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _userRepo.updateSurvey(
          userId: user.uid,
          ageGroup: _selectedAgeGroup ?? "Not specified",
          skinType: _selectedSkinType ?? "Not specified",
          goals: _selectedGoals,
          actualAge: int.tryParse(_actualAgeController.text),
          bmi: double.tryParse(_bmiController.text),
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
              child: SizedBox(
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
            ),
          ],
        ),
      ),
    );
  }

  bool _isStepValid() {
    switch (_currentStep) {
      case 0: return _selectedAgeGroup != null && _actualAgeController.text.isNotEmpty;
      case 1: return _bmiController.text.isNotEmpty && _waterGoalController.text.isNotEmpty;
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
          ..._ageGroups.map((opt) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: RadioListTile<String>(
              title: Text(opt, style: const TextStyle(fontSize: 14)),
              value: opt,
              groupValue: _selectedAgeGroup,
              onChanged: (val) => setState(() => _selectedAgeGroup = val),
              activeColor: primaryPink,
            ),
          )),
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
          _buildTextField(controller: _bmiController, label: "Your BMI", icon: Icons.monitor_weight, keyboardType: TextInputType.number),
          const SizedBox(height: 18),
          _buildTextField(controller: _waterGoalController, label: "Daily Water Goal (Liters)", icon: Icons.water_drop, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          const Text("★ Tip: Staying hydrated keeps your skin glowing!", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black54)),
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
                selectedColor: primaryPink.withOpacity(0.2),
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
                selectedColor: primaryPink.withOpacity(0.2),
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
                selectedColor: primaryPink.withOpacity(0.2),
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
              activeColor: primaryPink,
            ),
          ),
          if (_usesMedication) ...[
            const SizedBox(height: 24),
            const Text("Type of Medication", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: _medTypes.map((t) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: RadioListTile<String>(
                    title: Text(t, style: const TextStyle(fontSize: 11)),
                    value: t,
                    groupValue: _medicationType,
                    onChanged: (val) => setState(() => _medicationType = val),
                    contentPadding: EdgeInsets.zero,
                    activeColor: primaryPink,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            const Text("When do you use it?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: _medTimes.map((t) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: RadioListTile<String>(
                    title: Text(t, style: const TextStyle(fontSize: 11)),
                    value: t,
                    groupValue: _medicationTime,
                    onChanged: (val) => setState(() => _medicationTime = val),
                    contentPadding: EdgeInsets.zero,
                    activeColor: primaryPink,
                  ),
                ),
              )).toList(),
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
              activeColor: primaryPink,
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
