import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  // State variables for user inputs
  String _selectedMood = 'Amazing';
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedFactors = [];

  // Mood data mapping
  final List<Map<String, String>> _moods = [
    {'id': 'Amazing', 'emoji': '😍', 'label': 'Amazing'},
    {'id': 'Happy', 'emoji': '😁', 'label': 'Happy'},
    {'id': 'Calm', 'emoji': '😌', 'label': 'Calm'},
    {'id': 'Neutral', 'emoji': '😐', 'label': 'Neutral'},
    {'id': 'Sed', 'emoji': '🥺', 'label': 'Sed'},
    {'id': 'Angry', 'emoji': '😡', 'label': 'Angry'},
  ];

  // Selective factors
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

  void _saveMood() {
    final moodData = {
      'mood': _selectedMood,
      'note': _noteController.text,
      'factors': _selectedFactors,
      'timestamp': DateTime.now().toIso8601String(),
    };

    debugPrint("----- SAVED MOOD ENTRY -----");
    debugPrint(moodData.toString());
    debugPrint("----------------------------");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your mood log has been saved! 🌸'),
        backgroundColor: Color(0xFFFF527B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F2), Color(0xFFFFF5F6), Color(0xFFFFF0F2)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Navigation Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black54),
                      onPressed: () {},
                    ),
                    const Text(
                      'Mood Tracker',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D2A4A)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month_outlined, color: Colors.black54),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Dynamic Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE3E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'How are you feeling today,\nShinny? 🌸',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, color: Color(0xFF6C253B), fontWeight: FontWeight.w500, height: 1.4),
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Mood Section Selection
                const Text('1. How do you feel?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),

                // Top Row: 4 Emojis
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => _buildMoodCard(_moods[index]),
                ),
                const SizedBox(height: 10),

                // Bottom Row: 2 Centered Emojis
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: 2,
                    itemBuilder: (context, index) => _buildMoodCard(_moods[index + 4]),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. What's on your mind? text area layout
                const Text("2. What's on your mind? (optional)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    TextField(
                      controller: _noteController,
                      maxLength: 200,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write your thoughts...',
                        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                        fillColor: Colors.white.withValues(alpha: 0.6),
                        filled: true,
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFFFF5E84)),
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: Text('${_noteController.text.length}/200', style: const TextStyle(color: Colors.black38, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Selective Factors Selection Grid
                const Text('3. What affected your mood today?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: _factors.length,
                  itemBuilder: (context, index) {
                    final factor = _factors[index];
                    final isSelected = _selectedFactors.contains(factor['id']);
                    return InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedFactors.remove(factor['id']);
                          } else {
                            _selectedFactors.add(factor['id']);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFF0F3) : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF5E84) : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(factor['icon'], color: factor['color'], size: 18),
                            const SizedBox(width: 10),
                            Text(
                              factor['label'],
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Active Submit Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveMood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF527B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 1,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Save My Mood ', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('🌸', style: TextStyle(fontSize: 16)),
                      ],
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

  // Builder method for standard/active mood cards
  Widget _buildMoodCard(Map<String, String> mood) {
    final isSelected = _selectedMood == mood['id'];
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedMood = mood['id']!),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F3) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF5E84) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood['emoji']!, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              mood['label']!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFFF426F) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}