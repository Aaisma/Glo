import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JournalActivityScreen extends StatefulWidget {
  const JournalActivityScreen({super.key});

  @override
  State<JournalActivityScreen> createState() => _JournalActivityScreenState();
}

class _JournalActivityScreenState extends State<JournalActivityScreen> {
  bool isRecording = false;
  String timerText = "00:00";

  void _toggleRecording() {
    setState(() {
      isRecording = !isRecording;
      timerText = isRecording ? "Recording..." : "00:00";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isRecording ? "Recording started" : "Recording stopped"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String todayDate = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF3E63),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Journal",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              todayDate,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => _showMessage("No new notifications"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Mood Section
            const Text(
              "How are you feeling today?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF3E63)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                moodChip("I'm a bit stressed"),
                moodChip("I'm quite motivated"),
                moodChip("I'm indifferent"),
                moodChip("I feel calm"),
              ],
            ),

            const SizedBox(height: 24),

            // Write Journal
            const Text(
              "Write your journal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF3E63)),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write how you feel today...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Voice Journal
            const Text(
              "Voice Journal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF3E63)),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _toggleRecording,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF3E63)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mic, color: const Color(0xFFFF3E63)),
                    const SizedBox(width: 12),
                    Text(isRecording ? "Tap to stop" : "Tap to record", style: const TextStyle(fontSize: 16)),
                    const Spacer(),
                    Text(timerText, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Activity Section
            const Text(
              "What did you do today?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF3E63)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                activityCard("Log your activity", Icons.fitness_center, () => _showMessage("Activity logged")),
                activityCard("Log your energy", Icons.bolt, () => _showMessage("Energy logged")),
                activityCard("Gratitude note", Icons.favorite, () => _showMessage("Gratitude noted")),
              ],
            ),

            const SizedBox(height: 24),

            // Journal Streak Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("3 Day Streak", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Mon"), Text("Tue"), Text("Wed"), Text("Thu"), Text("Fri"), Text("Sat"), Text("Sun"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("Longest streak: 7 days", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3E63),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _showMessage("Journal saved successfully"),
                child: const Text("Save Journal", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget moodChip(String text) {
    return ActionChip(
      label: Text(text),
      backgroundColor: const Color(0xFFFF3E63).withOpacity(0.1),
      labelStyle: const TextStyle(color: Color(0xFFFF3E63)),
      onPressed: () => _showMessage("Mood selected: $text"),
    );
  }

  Widget activityCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFF3E63)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFF3E63), size: 28),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
