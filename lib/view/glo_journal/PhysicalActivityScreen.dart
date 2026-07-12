import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodel/write_journal_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../model/journal_entry_model.dart';

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

  final List<Map<String, dynamic>> activities = [
    {'name': 'Walking', 'icon': Icons.directions_walk, 'emoji': '🚶'},
    {'name': 'Run', 'icon': Icons.directions_run, 'emoji': '🏃'},
    {'name': 'Yoga', 'icon': Icons.self_improvement, 'emoji': '🧘'},
    {'name': 'Gym', 'icon': Icons.fitness_center, 'emoji': '🏋️'},
    {'name': 'Other', 'icon': Icons.more_horiz, 'emoji': '👟'},
  ];

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _saveActivity() async {
    final writeVM = context.read<WriteJournalViewModel>();
    final userVM = context.read<UserViewModel>();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    final activityData = activities.firstWhere((a) => a['name'] == selectedActivity);

    try {
      final entry = JournalEntryModel(
        id: const Uuid().v4(),
        userId: userId,
        userName: userVM.user?.name ?? 'User',
        title: "Workout: $selectedActivity",
        content: "Duration: ${_durationController.text} mins\nCalories: ${_caloriesController.text} kcal\nFeeling: $selectedFeeling",
        createdAt: DateTime.now(),
        mood: selectedFeeling,
        emoji: activityData['emoji'],
        category: 'activity',
      );

      await writeVM.repository.addJournal(entry);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity Logged Successfully! 💪')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
        title: const Text('Physical Activity', style: TextStyle(color: Color(0xFF2E2E2E), fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                children: [
                  const Text('Activity Type', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildActivityList(),
                  const SizedBox(height: 20),
                  _buildInputField('Duration (mins)', _durationController),
                  const SizedBox(height: 20),
                  _buildInputField('Calories Burned', _caloriesController),
                  const SizedBox(height: 20),
                  const Text('How do you feel?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildFeelingDropdown(),
                ],
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    return SizedBox(
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
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? primaryPink : Colors.transparent, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(act['icon'], color: isSelected ? primaryPink : Colors.black54),
                  Text(act['name'], style: TextStyle(fontSize: 11, color: isSelected ? primaryPink : Colors.black54)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildFeelingDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFeeling,
          isExpanded: true,
          items: ['Great', 'Good', 'Tired', 'Exhausted'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => selectedFeeling = v!),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: _saveActivity,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Save Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
