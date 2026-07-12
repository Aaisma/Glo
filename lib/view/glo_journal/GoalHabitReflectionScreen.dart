import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../viewmodel/journal_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../model/journal_model.dart';

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
    final viewModel = Provider.of<JournalViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    
    final content = "Goals Completed: ${isGoalsCompleted == true ? 'Yes' : 'No'}\n"
                    "Proud Habit: ${_proudHabitController.text}\n"
                    "Improvement: ${_improveTomorrowController.text}\n"
                    "Productivity Rating: $productivityRating/5";
    
    final journal = JournalModel(
      id: const Uuid().v4(),
      userId: userViewModel.user?.id ?? 'unknown',
      userName: userViewModel.user?.name ?? 'Anonymous',
      title: "Goal & Habit Reflection",
      content: content,
      mood: _getMoodFromRating(productivityRating),
      emoji: "💡",
      createdAt: DateTime.now(),
      category: 'reflection',
    );

    try {
      await viewModel.addJournal(journal);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reflection Saved Successfully! 💡')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save reflection: $e')),
        );
      }
    }
  }

  String _getMoodFromRating(int rating) {
    if (rating >= 4) return "Excellent";
    if (rating >= 3) return "Good";
    return "Reflective";
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: primaryPink),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Did I complete my goals today?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isGoalsCompleted = true;
                          });
                        },
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: isGoalsCompleted == true ? primaryPink : primaryPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Yes 🤩',
                            style: TextStyle(
                              color: isGoalsCompleted == true ? Colors.white : primaryPink,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isGoalsCompleted = false;
                          });
                        },
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: isGoalsCompleted == false ? primaryPink : primaryPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'No 🤨',
                            style: TextStyle(
                              color: isGoalsCompleted == false ? Colors.white : primaryPink,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'What habit am I proud of?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _proudHabitController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your habit...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'What can I improve tomorrow?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _improveTomorrowController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter improvements...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Productivity Today',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('😅', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 16),
                    ...List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            productivityRating = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Icon(
                            index < productivityRating ? Icons.star : Icons.star_border,
                            color: primaryPink,
                            size: 28,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _saveReflection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Reflection',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
