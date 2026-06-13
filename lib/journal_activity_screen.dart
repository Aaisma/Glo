import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JournalActivityScreen extends StatefulWidget {
  const JournalActivityScreen({super.key});

  @override
  State<JournalActivityScreen> createState() => _JournalActivityScreenState();
}

class _JournalActivityScreenState extends State<JournalActivityScreen> {
  // Navigation & Segment Controls
  int _activeSegmentIndex = 0; // 0 for Activity/Gratitude, 1 for Reminders/Streaks
  String selectedWorkout = 'Yoga';
  double workoutDuration = 30;
  bool dailyReminder = true;
  TimeOfDay reminderTime = const TimeOfDay(hour: 8, minute: 30);

  // Audio Mock State
  bool _isRecording = false;

  void _showVoiceRecordingSheet() {
    setState(() => _isRecording = true);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return ScaffoldMessenger(
          child: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Voice Journal",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Speak freely. We'll secure your thoughts.",
                    style: TextStyle(fontSize: 13, color: Colors.black45),
                  ),
                  const SizedBox(height: 32),
                  // Animated Audio Wave Blocks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 6,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3E63),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3E63),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.stop_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Recording... Tap to Stop & Save",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFF3E63)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      setState(() => _isRecording = false);
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );
    if (picked != null && picked != reminderTime) {
      setState(() => reminderTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String todayDate = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 1. Premium Header Bar Layout Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        "Today's Journal",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF263238)),
                      ),
                      Text(
                        todayDate,
                        style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.mic_none_rounded, size: 20, color: Color(0xFFFF3E63)),
                      onPressed: _showVoiceRecordingSheet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. High Density Core Input Card Setup
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daily Reflections",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF263238)),
                      decoration: InputDecoration(
                        hintText: "What's occupying your thoughts or energy today?",
                        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                        contentPadding: const EdgeInsets.all(12),
                        fillColor: const Color(0xFFFDFBF7),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Segment Control Toggles (Fixed Syntax Here)
              Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEBE6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeSegmentIndex = 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _activeSegmentIndex == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "Metrics & Gratitude",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _activeSegmentIndex == 0 ? const Color(0xFFFF3E63) : Colors.black54
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeSegmentIndex = 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _activeSegmentIndex == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "Streak & Reminders",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _activeSegmentIndex == 1 ? const Color(0xFFFF3E63) : Colors.black54
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Dynamic Screen Body Area
              Expanded(
                child: _activeSegmentIndex == 0
                    ? _buildMetricsAndGratitudeView()
                    : _buildStreakAndRemindersView(),
              ),
              const SizedBox(height: 14),

              // 5. Positive Quote Section Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEFE7FA), Color(0xFFE8DCF7)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Text('🌸 ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        "“Your life is a canvas; make sure you design it with bright colors.”",
                        style: TextStyle(fontSize: 11, color: Color(0xFF5E35B1), fontWeight: FontWeight.w600, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 6. Premium Save Execution Capsule Button
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Journal safely archived!")),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF3E63), Color(0xFFFF7A85)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFF3E63).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Save Journal Entry",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Content Block 1
  Widget _buildMetricsAndGratitudeView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fitness Card Layout
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Activity Metrics", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text("${workoutDuration.toInt()} mins", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF3E63))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Yoga', 'Running', 'Gym', 'Walking'].map((type) {
                  bool isSel = selectedWorkout == type;
                  return GestureDetector(
                    onTap: () => setState(() => selectedWorkout = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFFF3E63) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(type, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.black54)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Gratitude Entry View
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFF9E6), Color(0xFFFFF3CC)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('✨ ', style: TextStyle(fontSize: 14)),
                    Text("Today's Gratitude Focus", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF795548))),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: TextField(
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037), height: 1.4),
                    decoration: InputDecoration(
                      hintText: "What unique moment caused you to smile or feel thankful during your hours today?",
                      hintStyle: TextStyle(color: Colors.brown.withOpacity(0.4), fontSize: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Content Block 2
  Widget _buildStreakAndRemindersView() {
    return Column(
      children: [
        // Streak Card Layout
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Consistency Tracking", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                  bool complete = (day == 'M' || day == 'T' || day == 'W');
                  return Column(
                    children: [
                      Text(complete ? '🌸' : '⚪', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(day, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: complete ? const Color(0xFFFF3E63) : Colors.black38)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Reminder Settings Module
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.purple[50], shape: BoxShape.circle),
                    child: const Icon(Icons.alarm_rounded, color: Colors.purple, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Journal Reminder", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => dailyReminder ? _selectTime(context) : null,
                        child: Text(
                          "Trigger note at ${reminderTime.format(context)}",
                          style: TextStyle(fontSize: 11, color: dailyReminder ? const Color(0xFFFF3E63) : Colors.black38, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: dailyReminder,
                activeColor: const Color(0xFFFF3E63),
                activeTrackColor: const Color(0xFFFFE4E9),
                onChanged: (val) => setState(() => dailyReminder = val),
              ),
            ],
          ),
        ),
      ],
    );
  }
}