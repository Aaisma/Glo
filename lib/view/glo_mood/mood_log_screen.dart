import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glo/viewmodel/mood_view_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
class MoodLogScreen extends StatefulWidget {
  const MoodLogScreen({super.key});

  @override
  State<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends State<MoodLogScreen> {
  String _selectedMood = 'Amazing';
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedFactors = [];

  final List<Map<String, String>> _moods = [
    {'id': 'Amazing', 'emoji': '😍', 'label': 'Amazing'},
    {'id': 'Happy', 'emoji': '😁', 'label': 'Happy'},
    {'id': 'Calm', 'emoji': '😌', 'label': 'Calm'},
    {'id': 'Neutral', 'emoji': '😐', 'label': 'Neutral'},
    {'id': 'Sad', 'emoji': '🥺', 'label': 'Sad'},
    {'id': 'Angry', 'emoji': '😡', 'label': 'Angry'},
  ];

  final List<Map<String, dynamic>> _factors = [
    {'id': 'Sleep', 'label': 'Sleep', 'icon': LucideIcons.moon, 'color': Colors.blue},
    {'id': 'Food', 'label': 'Food', 'icon': LucideIcons.utensils, 'color': Colors.green},
    {'id': 'Work', 'label': 'Work', 'icon': LucideIcons.briefcase, 'color': Colors.amber},
    {'id': 'Study', 'label': 'Study', 'icon': LucideIcons.bookOpen, 'color': Colors.cyan},
    {'id': 'Stress', 'label': 'Stress', 'icon': LucideIcons.flame, 'color': Colors.orange},
    {'id': 'Hormones', 'label': 'Hormones', 'icon': LucideIcons.activity, 'color': Colors.purple},
    {'id': 'Thoughts', 'label': 'Thoughts', 'icon': LucideIcons.brain, 'color': Colors.indigo},
    {'id': 'SelfTalk', 'label': 'Self Talk', 'icon': LucideIcons.messageSquare, 'color': Colors.teal},
  ];

  // MVVM logic: Use the ViewModel to save the mood
  Future<void> _saveMood() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "demo_user";

    try {
      await context.read<MoodViewModel>().logMood(
        userId: userId,
        moodType: _selectedMood,
        note: _noteController.text,
        factors: _selectedFactors,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your mood log has been saved! 🌸'),
            backgroundColor: Color(0xFFFF527B),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Go back to dashboard after saving
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving mood: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F2), Color(0xFFFFF5F6), Color(0xFFFFF0F2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Mood Tracker',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2A4A)),
                    ),
                    const SizedBox(width: 48), // Spacer
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE3E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'How are you feeling today, Shinny? 🌸',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF6C253B), fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('1. How do you feel?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _moods.length,
                  itemBuilder: (context, index) => _buildMoodCard(_moods[index]),
                ),
                const SizedBox(height: 16),
                const Text("2. What's on your mind? (optional)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLength: 200,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Write your thoughts...',
                    fillColor: Colors.white.withOpacity(0.6),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('3. What affected your mood today?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _factors.map((factor) {
                    final isSelected = _selectedFactors.contains(factor['id']);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedFactors.remove(factor['id']);
                          } else {
                            _selectedFactors.add(factor['id']);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFF0F3) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? const Color(0xFFFF5E84) : Colors.transparent),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(factor['icon'], color: factor['color'], size: 15),
                            const SizedBox(width: 6),
                            Text(factor['label'], style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveMood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF527B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text('Save My Mood 🌸', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodCard(Map<String, String> mood) {
    final isSelected = _selectedMood == mood['id'];
    return InkWell(
      onTap: () => setState(() => _selectedMood = mood['id']!),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F3) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? const Color(0xFFFF5E84) : Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood['emoji']!, style: const TextStyle(fontSize: 24)),
            Text(mood['label']!, style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFFFF426F) : Colors.black54)),
          ],
        ),
      ),
    );
  }
}