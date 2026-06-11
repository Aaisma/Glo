import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  String _selectedMood = 'Amazing';
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedFactors = [];

  final List<Map<String, String>> _moods = [
    {'id': 'Amazing', 'emoji': '😍', 'label': 'Amazing'},
    {'id': 'Happy', 'emoji': '😁', 'label': 'Happy'},
    {'id': 'Calm', 'emoji': '😌', 'label': 'Calm'},
    {'id': 'Neutral', 'emoji': '😐', 'label': 'Neutral'},
    {'id': 'Sed', 'emoji': '🥺', 'label': 'Sed'},
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

  void _saveMood() {
    final moodData = {
      'mood': _selectedMood,
      'note': _noteController.text,
      'factors': _selectedFactors,
      'timestamp': DateTime.now().toIso8601String(),
    };

    debugPrint(moodData.toString());

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
      // Prevents keyboard from pushing layouts out of alignment bounds
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

                // 1. App Header Layout (Compact)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black54),
                      onPressed: () {},
                    ),
                    const Text(
                      'Mood Tracker',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2A4A)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month_outlined, size: 20, color: Colors.black54),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 2. Greeting Banner
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

                // 3. Mood Selection Header
                const Text('1. How do you feel?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),

                // Grid layout condensed into a single balanced grid view
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Changed to 3 columns to natively fit 6 emojis in 2 clean rows
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _moods.length,
                  itemBuilder: (context, index) => _buildMoodCard(_moods[index]),
                ),
                const SizedBox(height: 16),

                // 4. Text Input Field
                const Text("2. What's on your mind? (optional)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    TextField(
                      controller: _noteController,
                      maxLength: 200,
                      maxLines: 2, // Dropped to 2 lines to save valuable screenspace
                      decoration: InputDecoration(
                        hintText: 'Write your thoughts...',
                        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                        fillColor: Colors.white.withValues(alpha: 0.6),
                        filled: true,
                        counterText: "",
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFFF5E84)),
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 12,
                      child: Text('${_noteController.text.length}/200', style: const TextStyle(color: Colors.black38, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 5. Factors Section
                const Text('3. What affected your mood today?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),

                // Wrap widget auto-manages layouts tightly without wasting extra grid spacing bounds
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _factors.map((factor) {
                    final isSelected = _selectedFactors.contains(factor['id']);
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
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
                        duration: const Duration(milliseconds: 120),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFF0F3) : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF5E84) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Essential for tight Wrap tags
                          children: [
                            Icon(factor['icon'], color: factor['color'], size: 15),
                            const SizedBox(width: 6),
                            Text(
                              factor['label'],
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Spacer pushes the save button seamlessly to the very bottom edge of the screen layout container
                const Spacer(),

                // 6. Sticky Bottom Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveMood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF527B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Save My Mood ', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('🌸', style: TextStyle(fontSize: 15)),
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

  Widget _buildMoodCard(Map<String, String> mood) {
    final isSelected = _selectedMood == mood['id'];
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selectedMood = mood['id']!),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F3) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF5E84) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood['emoji']!, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 2),
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