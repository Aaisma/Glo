import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodel/write_journal_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../model/journal_entry_model.dart';

class WriteLetterScreen extends StatefulWidget {
  const WriteLetterScreen({super.key});

  @override
  State<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends State<WriteLetterScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  DateTime _unlockDate = DateTime.now().add(const Duration(days: 30));

  Future<void> _saveLetter() async {
    final subject = _subjectController.text.trim();
    final content = _contentController.text.trim();

    if (subject.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both subject and content.')),
      );
      return;
    }

    final writeVM = context.read<WriteJournalViewModel>();
    final userVM = context.read<UserViewModel>();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userName = userVM.user?.name ?? 'User';

    try {
      final letter = JournalEntryModel(
        id: const Uuid().v4(),
        userId: userId,
        userName: userName,
        title: subject,
        content: content,
        createdAt: DateTime.now(),
        mood: 'Future',
        emoji: '💌',
        category: 'future_letter',
        unlockDate: _unlockDate,
      );

      await writeVM.repository.addJournal(letter);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Letter Sealed Successfully! ✉️'),
            backgroundColor: Color(0xFFFF2D65),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save letter: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Write to Future Self", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFF2D65), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Subject", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: "e.g., A message to myself in 2025",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Unlock Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(DateFormat('MMMM dd, yyyy').format(_unlockDate), 
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFFF2D65))),
              trailing: const Icon(Icons.calendar_month, color: Color(0xFFFF2D65)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _unlockDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) {
                  setState(() => _unlockDate = picked);
                }
              },
            ),
            const SizedBox(height: 20),
            const Text("Your Letter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 12,
              decoration: InputDecoration(
                hintText: "What do you want to tell your future self?",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2D65),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _saveLetter,
                child: const Text("Seal & Save Letter ✉️", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
