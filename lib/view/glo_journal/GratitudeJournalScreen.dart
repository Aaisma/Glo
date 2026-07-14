import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../viewmodel/journal_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../model/journal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GratitudeJournalScreen extends StatefulWidget {
  const GratitudeJournalScreen({Key? key}) : super(key: key);

  @override
  State<GratitudeJournalScreen> createState() => _GratitudeJournalScreenState();
}

class _GratitudeJournalScreenState extends State<GratitudeJournalScreen> {
  final Color primaryPink = const Color(0xFFFF2D65);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);

  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveGratitude() async {
    final content = _controllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .join("\n");

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please share at least one thing you are grateful for!')),
      );
      return;
    }

    final viewModel = Provider.of<JournalViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    final journal = JournalModel(
      id: const Uuid().v4(),
      userId: FirebaseAuth.instance.currentUser?.uid ?? userViewModel.user?.id ?? 'unknown',
      userName: userViewModel.user?.name ?? 'Anonymous',
      title: "Daily Gratitude",
      content: "I'm grateful for:\n$content",
      mood: "Grateful",
      emoji: "💖",
      createdAt: DateTime.now(),
      category: 'gratitude',
    );

    try {
      await viewModel.addJournal(journal);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gratitude Saved Successfully! 🌸')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
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
          'Gratitude Journal',
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
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  const Text(
                    "I'm grateful for...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_controllers.length, (index) => _buildGratitudeField(index + 1, _controllers[index])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveGratitude,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Gratitude',
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

  Widget _buildGratitudeField(int number, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            '$number',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryPink.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter item...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 15, color: Color(0xFF2E2E2E)),
            ),
          ),
        ],
      ),
    );
  }
}
