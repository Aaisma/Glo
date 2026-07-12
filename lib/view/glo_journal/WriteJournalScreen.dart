import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/write_journal_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';

class WriteJournalScreen extends StatefulWidget {
  const WriteJournalScreen({Key? key}) : super(key: key);

  @override
  State<WriteJournalScreen> createState() => _WriteJournalScreenState();
}

class _WriteJournalScreenState extends State<WriteJournalScreen> {
  final TextEditingController _textController = TextEditingController();
  final Color primaryPink = const Color(0xFFFF2D65);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final writeVM = context.read<WriteJournalViewModel>();
    final userVM = context.read<UserViewModel>();

    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before saving!')),
      );
      return;
    }

    if (userVM.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found. Please log in again.')),
      );
      return;
    }

    try {
      // Use the first line as the title, or a default one
      String content = _textController.text.trim();
      String title = content.split('\n').first;
      if (title.length > 30) title = title.substring(0, 27) + '...';

      await writeVM.saveEntry(
        userId: userVM.user!.id,
        userName: userVM.user!.name,
        title: title,
        content: content,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal Saved Successfully! 🌸')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving journal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final writeVM = context.watch<WriteJournalViewModel>();

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
          'Write Journal',
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: Text(
              'Save',
              style: TextStyle(
                color: primaryPink,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '"Start where you are. Use what you have. Do what you can."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'How is your day?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          maxLength: 2000,
                          decoration: const InputDecoration(
                            hintText: 'Write your thoughts...',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          onChanged: (text) {
                            setState(() {});
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '${_textController.text.length}/2000',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'How are you feeling?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMoodItem(writeVM, '🤩', 'Amazing'),
                  _buildMoodItem(writeVM, '😀', 'Happy'),
                  _buildMoodItem(writeVM, '😐', 'Calm'),
                  _buildMoodItem(writeVM, '😢', 'Sad'),
                  _buildMoodItem(writeVM, '😡', 'Angry'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildActionButton(Icons.camera_alt_outlined, 'Add Photo')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildActionButton(Icons.sentiment_satisfied_alt, 'Add Mood')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildActionButton(Icons.local_offer_outlined, 'Add Tags')),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Journal',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodItem(WriteJournalViewModel viewModel, String emoji, String label) {
    bool isSelected = viewModel.selectedMood == label;
    return GestureDetector(
      onTap: () {
        viewModel.updateMood(label, emoji);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? primaryPink.withOpacity(0.2) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? primaryPink : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryPink : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryPink, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
