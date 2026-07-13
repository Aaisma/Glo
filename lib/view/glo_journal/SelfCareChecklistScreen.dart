import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../viewmodel/journal_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../model/journal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    final viewModel = Provider.of<JournalViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    
    final content = "Self-care completed today:\n" + checkedItems.map((e) => "- $e").join("\n");
    
    final journal = JournalModel(
      id: const Uuid().v4(),
      userId: FirebaseAuth.instance.currentUser?.uid ?? userViewModel.user?.id ?? 'unknown',
      userName: userViewModel.user?.name ?? 'Anonymous',
      title: "Self-care Checklist",
      content: content,
      mood: "Productive",
      emoji: "✅",
      createdAt: DateTime.now(),
      category: 'self_care',
    );

    try {
      await viewModel.addJournal(journal);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checklist Saved Successfully! ✨')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save checklist: $e')),
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
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: primaryPink),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _checklistItems.length,
                  itemBuilder: (context, index) {
                    final item = _checklistItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: primaryPink.withOpacity(0.4),
                            ),
                            child: Checkbox(
                              value: item['checked'],
                              activeColor: primaryPink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (bool? value) {
                                setState(() {
                                  item['checked'] = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item['title'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2E2E2E),
                              ),
                            ),
                          ),
                          Icon(
                            item['icon'],
                            color: primaryPink,
                            size: 22,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChecklist,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Checklist',
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
    );
  }
}
