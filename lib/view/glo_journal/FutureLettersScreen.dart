import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../viewmodel/future_letters_viewmodel.dart';
import '../../viewmodel/journal_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../model/journal_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FutureLettersScreen extends StatefulWidget {
  const FutureLettersScreen({Key? key}) : super(key: key);

  @override
  State<FutureLettersScreen> createState() => _FutureLettersScreenState();
}

class _FutureLettersScreenState extends State<FutureLettersScreen> {
  final Color primaryPink = const Color(0xFFFF2D65);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);

  void _showWriteLetterDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    DateTime unlockDate = DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Write to Future Self', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Letter Title (e.g., Dear Future Me)'),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TextField(
                  controller: contentController,
                  maxLines: null,
                  decoration: const InputDecoration(hintText: 'Write your heart out...', border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Unlock Date'),
                subtitle: Text(DateFormat('MMMM dd, yyyy').format(unlockDate)),
                trailing: Icon(Icons.calendar_today, color: primaryPink),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: unlockDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) {
                    setModalState(() => unlockDate = picked);
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty || contentController.text.isEmpty) return;
                  
                  final userViewModel = Provider.of<UserViewModel>(context, listen: false);
                  
                  final letter = JournalModel(
                    id: const Uuid().v4(),
                    userId: FirebaseAuth.instance.currentUser?.uid ?? userViewModel.user?.id ?? 'unknown',
                    userName: userViewModel.user?.name ?? 'Anonymous',
                    title: titleController.text,
                    content: contentController.text,
                    mood: 'Future',
                    emoji: '💌',
                    createdAt: DateTime.now(),
                    category: 'future_letter',
                    unlockDate: unlockDate,
                  );
                  
                  await Provider.of<JournalViewModel>(context, listen: false).addJournal(letter);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Seal Letter ✉️', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FutureLettersViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);
    final userId = userViewModel.user?.id ?? '';

    return Scaffold(
      backgroundColor: backgroundSoftPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryPink, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Future Letters', style: TextStyle(color: Color(0xFF2E2E2E), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildToggleButtons(viewModel),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<JournalModel>>(
                stream: userId.isEmpty ? Stream.value([]) : viewModel.getLettersStream(userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final now = DateTime.now();
                  final letters = snapshot.data!;
                  final displayedLetters = letters.where((l) {
                    final isUnlocked = l.unlockDate != null && l.unlockDate!.isBefore(now);
                    return viewModel.isLockedSelected ? !isUnlocked : isUnlocked;
                  }).toList();

                  if (displayedLetters.isEmpty) {
                    return Center(child: Text(viewModel.isLockedSelected ? "No locked letters yet." : "No unlocked letters yet."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: displayedLetters.length,
                    itemBuilder: (context, index) => _buildLetterItem(displayedLetters[index]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: _showWriteLetterDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('+ Write New Letter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons(FutureLettersViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 45,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => viewModel.toggleTab(true),
                child: Container(
                  decoration: BoxDecoration(
                    color: viewModel.isLockedSelected ? primaryPink : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text('Locked', style: TextStyle(color: viewModel.isLockedSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => viewModel.toggleTab(false),
                child: Container(
                  decoration: BoxDecoration(
                    color: !viewModel.isLockedSelected ? primaryPink : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text('Unlocked', style: TextStyle(color: !viewModel.isLockedSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterItem(JournalModel letter) {
    bool isLocked = letter.unlockDate != null && letter.unlockDate!.isAfter(DateTime.now());

    return GestureDetector(
      onTap: isLocked ? () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("This letter is locked until ${DateFormat('MMMM dd, yyyy').format(letter.unlockDate!)}")));
      } : () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(letter.title),
            content: Text(letter.content),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: primaryPink.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: Icon(isLocked ? Icons.lock_outline : Icons.mail_outline, color: primaryPink, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(letter.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E2E2E))),
                  const SizedBox(height: 6),
                  Text(isLocked ? 'Unlocks on' : 'Unlocked on', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                  Text(DateFormat('MMM dd, yyyy').format(letter.unlockDate!), style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(isLocked ? Icons.lock_outline : Icons.drafts_outlined, color: primaryPink.withOpacity(0.6), size: 22),
          ],
        ),
      ),
    );
  }
}
