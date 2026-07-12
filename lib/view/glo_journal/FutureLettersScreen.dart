import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodel/future_letters_viewmodel.dart';
import '../../model/journal_entry_model.dart';
import 'WriteLetterScreen.dart';

class FutureLettersScreen extends StatefulWidget {
  const FutureLettersScreen({Key? key}) : super(key: key);

  @override
  State<FutureLettersScreen> createState() => _FutureLettersScreenState();
}

class _FutureLettersScreenState extends State<FutureLettersScreen> {
  final Color primaryPink = const Color(0xFFFF2D65);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FutureLettersViewModel>();
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
          'Future Letters',
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
            const SizedBox(height: 10),
            _buildToggleButtons(viewModel),
            const SizedBox(height: 20),
            Expanded(
              child: userId.isEmpty
                  ? const Center(child: Text("Please log in to view letters."))
                  : StreamBuilder<List<JournalEntryModel>>(
                      stream: viewModel.repository.getJournals(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final now = DateTime.now();
                        final letters = (snapshot.data ?? [])
                            .where((j) => j.category == 'future_letter')
                            .toList();
                        
                        final displayedLetters = letters.where((l) {
                          final isUnlocked = l.unlockDate != null && l.unlockDate!.isBefore(now);
                          return viewModel.isLockedSelected ? !isUnlocked : isUnlocked;
                        }).toList();

                        if (displayedLetters.isEmpty) {
                          return Center(
                            child: Text(viewModel.isLockedSelected
                                ? "No locked letters yet. 🔒"
                                : "No unlocked letters yet. ✉️"),
                          );
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WriteLetterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  '+ Write New Letter',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
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
                  child: Text(
                    'Locked',
                    style: TextStyle(
                      color: viewModel.isLockedSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  child: Text(
                    'Unlocked',
                    style: TextStyle(
                      color: !viewModel.isLockedSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterItem(JournalEntryModel letter) {
    bool isLocked = letter.unlockDate != null && letter.unlockDate!.isAfter(DateTime.now());

    return GestureDetector(
      onTap: isLocked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "This letter is locked until ${DateFormat('MMMM dd, yyyy').format(letter.unlockDate!)}")));
            }
          : () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(letter.title),
                  content: SingleChildScrollView(child: Text(letter.content)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
                  ],
                ),
              );
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryPink.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(isLocked ? Icons.lock_outline : Icons.mail_outline, color: primaryPink, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    letter.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLocked ? 'Unlocks on' : 'Unlocked on',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM dd, yyyy').format(letter.unlockDate!),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isLocked ? Icons.lock_outline : Icons.drafts_outlined,
              color: primaryPink.withOpacity(0.6),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
