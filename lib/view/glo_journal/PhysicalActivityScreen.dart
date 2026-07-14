import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../viewmodel/journal_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../model/journal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhysicalActivityScreen extends StatefulWidget {
  const PhysicalActivityScreen({Key? key}) : super(key: key);

  @override
  State<PhysicalActivityScreen> createState() => _PhysicalActivityScreenState();
}

class _PhysicalActivityScreenState extends State<PhysicalActivityScreen> {
  final Color primaryPink = const Color(0xFFFF2D65);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);

  String selectedActivity = 'Walking';
  String selectedFeeling = 'Great';
  final TextEditingController _durationController = TextEditingController(text: '30');
  final TextEditingController _caloriesController = TextEditingController(text: '250');

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _saveActivity() async {
    final viewModel = Provider.of<JournalViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    
    final content = "Activity: $selectedActivity\n"
                    "Duration: ${_durationController.text} minutes\n"
                    "Calories: ${_caloriesController.text} kcal\n"
                    "Feeling: $selectedFeeling";
    
    final journal = JournalModel(
      id: const Uuid().v4(),
      userId: FirebaseAuth.instance.currentUser?.uid ?? userViewModel.user?.id ?? 'unknown',
      userName: userViewModel.user?.name ?? 'Anonymous',
      title: "Physical Activity: $selectedActivity",
      content: content,
      mood: selectedFeeling,
      emoji: _getIconForActivity(selectedActivity),
      createdAt: DateTime.now(),
      category: 'activity',
    );

    try {
      await viewModel.addJournal(journal);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity Saved Successfully! 💪')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save activity: $e')),
        );
      }
    }
  }

  String _getIconForActivity(String activity) {
    switch (activity) {
      case 'Walking': return '🚶';
      case 'Run': return '🏃';
      case 'Yoga': return '🧘';
      case 'Gym': return '🏋️';
      default: return '👟';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundSoftPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryPink, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Physical Activity',
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
                Icon(Icons.keyboard_arrow_down, color: primaryPink),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                children: [
                  const Text(
                    'Activity Type',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E2E2E)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final act = activities[index];
                        final isSelected = selectedActivity == act['name'];
                        return GestureDetector(
                          onTap: () => setState(() => selectedActivity = act['name']),
                          child: Container(
                            width: 65,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? primaryPink : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(act['icon'], color: isSelected ? primaryPink : Colors.black54),
                                const SizedBox(height: 4),
                                Text(
                                  act['name'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? primaryPink : Colors.black54,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputField('Duration (minutes)', _durationController, TextInputType.number),
                  const SizedBox(height: 20),
                  _buildInputField('Calories Burned (kcal)', _caloriesController, TextInputType.number),
                  const SizedBox(height: 20),
                  const Text(
                    'How do you feel after activity?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E2E2E)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFeeling,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: primaryPink),
                        items: ['Great', 'Good', 'Tired', 'Exhausted'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(color: Color(0xFF2E2E2E))),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedFeeling = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Activity',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E2E2E)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: type,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Color(0xFF2E2E2E)),
          ),
        ),
      ],
    );
  }

  final List<Map<String, dynamic>> activities = [
    {'name': 'Walking', 'icon': Icons.directions_walk},
    {'name': 'Run', 'icon': Icons.directions_run},
    {'name': 'Yoga', 'icon': Icons.self_improvement},
    {'name': 'Gym', 'icon': Icons.fitness_center},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];
}
