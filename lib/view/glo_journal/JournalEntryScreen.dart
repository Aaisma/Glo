import 'package:flutter/material.dart';
import 'ActivitySelectionScreen.dart';
import '../../viewmodel/journal_entry_viewmodel.dart';
class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  // Initialize your MVVM brain object inside the state
  final JournalEntryViewModel _viewModel = JournalEntryViewModel();

  bool _isVoiceRecording = false;
  String _selectedPrompt = "";
  final TextEditingController _journalController = TextEditingController();

  final Map<String, String> _selectedActivities = {
    "Physical Activity": "Add",
    "Self Care": "Add",
    "Lifestyle": "Add",
    "Mood": "Add",
  };

  final List<Map<String, dynamic>> _prompts = [
    {"text": "My own words", "icon": Icons.wb_sunny_outlined, "color": const Color(0xFFFF3E63)},
    {"text": "I'm so excited about", "icon": Icons.chat_bubble_outline_rounded, "color": Colors.purple},
    {"text": "I'm grateful for", "icon": Icons.card_giftcard_rounded, "color": Colors.amber},
    {"text": "I survived", "icon": Icons.water_drop_outlined, "color": Colors.teal},
  ];

  final List<Map<String, dynamic>> _activitiesStructure = [
    {"label": "Physical Activity", "icon": Icons.directions_run_rounded, "color": const Color(0xFFFF3E63)},
    {"label": "Self Care", "icon": Icons.spa_rounded, "color": const Color(0xFF673AB7)},
    {"label": "Lifestyle", "icon": Icons.star_rounded, "color": const Color(0xFF1976D2)},
    {"label": "Mood", "icon": Icons.sentiment_satisfied_rounded, "color": const Color(0xFFE65100)},
  ];

  // Logic to process the collection upload when clicking 'Journal Today'
  void _submitJournalToBackend() async {
    final String textInput = _journalController.text.trim();

    if (textInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a quick entry before logging! 📝')),
      );
      return;
    }

    // Call the Viewmodel background upload function
    bool isSavedSuccessfully = await _viewModel.uploadJournalEntry(
      journalText: textInput,
      quickPrompt: _selectedPrompt,
      currentActivities: _selectedActivities,
    );

    if (isSavedSuccessfully && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal logged to backend! 🎉')),
      );

      // Clean up inputs on success
      setState(() {
        _journalController.clear();
        _selectedPrompt = "";
        _selectedActivities.updateAll((key, value) => "Add");
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database upload failed. Check your connection.')),
      );
    }
  }

  void _navigateToActivitySelection() async {
    final Map<String, String>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivitySelectionScreen(
          initialSelections: Map<String, String>.from(_selectedActivities),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedActivities.addAll(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header Navigation Bar Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Column(
                            children: [
                              Text(
                                "Today's Journal",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "May 24, 2026",
                                style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, size: 22, color: Colors.black87),
                            onPressed: () {},
                          ),
                        ],
                      ),

                      const Text(
                        "How are you feeling today?",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                      ),

                      // Horizontal Quick Prompts Selector List Row
                      SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _prompts.length,
                          itemBuilder: (context, index) {
                            final prompt = _prompts[index];
                            final isSelected = _selectedPrompt == prompt["text"];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPrompt = prompt["text"];
                                  _journalController.text = "${prompt["text"]}: ";
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFFFF0F2) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFFF3E63) : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(prompt["icon"], size: 16, color: prompt["color"]),
                                    const SizedBox(width: 8),
                                    Text(
                                      prompt["text"],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? const Color(0xFFFF3E63) : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Inline Writing Pad Text Input Card Area
                      Container(
                        width: double.infinity,
                        height: 125,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFFFF3E63)),
                                SizedBox(width: 8),
                                Text(
                                  "Write your journal",
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: TextField(
                                controller: _journalController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF263238), height: 1.4),
                                decoration: const InputDecoration(
                                  hintText: "Write how you feel today...",
                                  hintStyle: TextStyle(color: Colors.black38, fontSize: 12),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Voice Journal Card Module
                      GestureDetector(
                        onTap: () => setState(() => _isVoiceRecording = !_isVoiceRecording),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _isVoiceRecording ? const Color(0xFFFFF0F2) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isVoiceRecording ? const Color(0xFFFF3E63).withValues(alpha: 0.3) : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: _isVoiceRecording ? const Color(0xFFFF3E63) : const Color(0xFFFFF0F2),
                                child: Icon(
                                  _isVoiceRecording ? Icons.stop_rounded : Icons.mic_none_rounded,
                                  color: _isVoiceRecording ? Colors.white : const Color(0xFFFF3E63),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Voice Journal",
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isVoiceRecording ? "Recording active audio notes..." : "Record your thoughts",
                                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (_isVoiceRecording)
                                const Text(
                                  "Tap to stop",
                                  style: TextStyle(fontSize: 11, color: Color(0xFFFF3E63), fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Clean Activities Row Layout Module
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "My Activities",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                              ),
                              TextButton(
                                onPressed: _navigateToActivitySelection,
                                child: const Text("View all", style: TextStyle(color: Color(0xFFFF3E63), fontSize: 12, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                          Row(
                            children: _activitiesStructure.map((item) {
                              final currentSelectionValue = _selectedActivities[item["label"]] ?? "Add";
                              final hasCustomValue = currentSelectionValue != "Add";

                              return Expanded(
                                child: GestureDetector(
                                  onTap: _navigateToActivitySelection,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: hasCustomValue ? const Color(0xFFFFF0F2) : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: hasCustomValue ? item["color"] : Colors.transparent,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(item["icon"], size: 20, color: item["color"]),
                                        const SizedBox(height: 6),
                                        Text(
                                          item["label"],
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          hasCustomValue ? currentSelectionValue : "+ Add",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: item["color"]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // Journal Streak Tracker Analytics Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFFFFF0F2),
                                  radius: 18,
                                  child: Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF3E63), size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text("3 ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFFFF3E63))),
                                        Text("day streak", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF263238))),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Longest streak: 7 days ✨",
                                      style: TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  children: ['Mon', 'Tue', 'Wed'].map((day) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(color: Color(0xFFFF3E63), shape: BoxShape.circle),
                                      child: const Icon(Icons.check, size: 10, color: Colors.white),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Connected your gradient button to MVVM state listeners
                            GestureDetector(
                              onTap: _viewModel.isLoading ? null : _submitJournalToBackend,
                              child: ListenableBuilder(
                                  listenable: _viewModel,
                                  builder: (context, child) {
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 11),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFFFF3E63), Color(0xFFFF7A85)]),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: _viewModel.isLoading
                                            ? [
                                          const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        ]
                                            : [
                                          const Icon(Icons.edit_document, size: 16, color: Colors.white),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "Journal Today",
                                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}