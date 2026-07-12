import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodel/write_journal_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../model/journal_entry_model.dart';

class SelfCareChecklistScreen extends StatefulWidget {
  const SelfCareChecklistScreen({Key? key}) : super(key: key);

  @override
  State<SelfCareChecklistScreen> createState() => _SelfCareChecklistScreenState();
}

class _SelfCareChecklistScreenState extends State<SelfCareChecklistScreen> {
  final Color primaryPink = const Color(0xFFFF2D65);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);

  final List<Map<String, dynamic>> _checklistItems = [
    {'title': 'Drink enough water', 'icon': Icons.opacity, 'checked': false},
    {'title': 'Took my medication', 'icon': Icons.medication_outlined, 'checked': false},
    {'title': '8+ hours sleep', 'icon': Icons.access_time, 'checked': false},
    {'title': 'Exercise', 'icon': Icons.fitness_center, 'checked': false},
    {'title': 'Skincare routine', 'icon': Icons.face_retouching_natural, 'checked': false},
    {'title': 'Meditation', 'icon': Icons.self_improvement, 'checked': false},
    {'title': 'Read a book', 'icon': Icons.menu_book, 'checked': false},
    {'title': 'Healthy meals', 'icon': Icons.favorite_border, 'checked': false},
    {'title': 'Took vitamins', 'icon': Icons.assignment_turned_in_outlined, 'checked': false},
  ];

  Future<void> _saveChecklist() async {
    final checkedItems = _checklistItems
        .where((item) => item['checked'] == true)
        .map((item) => item['title'])
        .toList();

    if (checkedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check at least one item!')),
      );
      return;
    }

    final writeVM = context.read<WriteJournalViewModel>();
    final userVM = context.read<UserViewModel>();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      final summary = "Self-care items completed:\n" + checkedItems.map((i) => "- $i").join("\n");
      
      final journal = JournalEntryModel(
        id: const Uuid().v4(),
        userId: userId,
        userName: userVM.user?.name ?? 'User',
        title: "Self-care Check-in",
        content: summary,
        mood: "Productive",
        emoji: "✅",
        createdAt: DateTime.now(),
        category: 'self_care',
      );

      await writeVM.repository.addJournal(journal);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checklist Saved! ✨')),
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
        title: const Text(
          'Self-care Checklist',
          style: TextStyle(color: Color(0xFF2E2E2E), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text('Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _checklistItems.length,
                  itemBuilder: (context, index) {
                    final item = _checklistItems[index];
                    return CheckboxListTile(
                      value: item['checked'],
                      activeColor: primaryPink,
                      title: Text(item['title'], style: const TextStyle(fontSize: 15)),
                      secondary: Icon(item['icon'], color: primaryPink),
                      onChanged: (val) => setState(() => item['checked'] = val),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _saveChecklist,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Checklist', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
