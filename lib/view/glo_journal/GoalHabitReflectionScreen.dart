import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodel/goal_reflection_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../viewmodel/write_journal_viewmodel.dart';
import '../../model/journal_entry_model.dart';

class GoalHabitReflectionScreen extends StatefulWidget {
  const GoalHabitReflectionScreen({Key? key}) : super(key: key);

  @override
  State<GoalHabitReflectionScreen> createState() => _GoalHabitReflectionScreenState();
}

class _GoalHabitReflectionScreenState extends State<GoalHabitReflectionScreen> {
  final Color primaryPink = const Color(0xFFFF2D65);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);

  bool? isGoalsCompleted = true;
  final TextEditingController _proudHabitController = TextEditingController();
  final TextEditingController _improveTomorrowController = TextEditingController();
  int productivityRating = 4;

  @override
  void dispose() {
    _proudHabitController.dispose();
    _improveTomorrowController.dispose();
    super.dispose();
  }

  Future<void> _saveReflection() async {
    final userVM = context.read<UserViewModel>();
    final writeVM = context.read<WriteJournalViewModel>();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (_proudHabitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share a habit you are proud of!')),
      );
      return;
    }

    try {
      final entry = JournalEntryModel(
        id: const Uuid().v4(),
        userId: userId,
        userName: userVM.user?.name ?? 'User',
        title: "Daily Reflection",
        content: "Goals Completed: ${isGoalsCompleted == true ? 'Yes' : 'No'}\n"
            "Proud Habit: ${_proudHabitController.text}\n"
            "To Improve: ${_improveTomorrowController.text}\n"
            "Productivity: $productivityRating/5",
        createdAt: DateTime.now(),
        mood: productivityRating >= 4 ? 'Amazing' : 'Reflective',
        emoji: '💡',
        category: 'reflection',
      );

      await writeVM.repository.addJournal(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reflection Saved Successfully! ✨')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving reflection: $e')),
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
        title: const Text(
          'Goal & Habit Reflection',
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Today',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Did I complete my goals today?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E2E2E)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildGoalToggle(true, 'Yes 🤩')),
                    const SizedBox(width: 14),
                    Expanded(child: _buildGoalToggle(false, 'No 🤨')),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'What habit am I proud of?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E2E2E)),
                ),
                const SizedBox(height: 10),
                _buildTextField(_proudHabitController, 'Enter your habit...'),
                const SizedBox(height: 24),
                const Text(
                  'What can I improve tomorrow?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E2E2E)),
                ),
                const SizedBox(height: 10),
                _buildTextField(_improveTomorrowController, 'Enter improvements...'),
                const SizedBox(height: 24),
                const Text(
                  'Productivity Today',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E2E2E)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('😅', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 16),
                    ...List.generate(5, (index) => _buildStar(index)),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveReflection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Reflection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalToggle(bool val, String label) {
    bool isSelected = isGoalsCompleted == val;
    return GestureDetector(
      onTap: () => setState(() => isGoalsCompleted = val),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isSelected ? primaryPink : primaryPink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : primaryPink,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: const TextStyle(color: Colors.grey, fontSize: 13)),
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  Widget _buildStar(int index) {
    return GestureDetector(
      onTap: () => setState(() => productivityRating = index + 1),
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Icon(
          index < productivityRating ? Icons.star : Icons.star_border,
          color: primaryPink,
          size: 28,
        ),
      ),
    );
  }
}
