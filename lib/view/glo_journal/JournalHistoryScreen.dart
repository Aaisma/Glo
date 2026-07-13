// C:/Users/Samjhana/Desktop/samglo/lib/view/glo_journal/JournalHistoryScreen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/journal_history_viewmodel.dart';
import '../../viewmodel/session_provider.dart';
import '../../model/journal_model.dart';
import 'JournalCalendarViewScreen.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({Key? key}) : super(key: key);

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  final Color primaryPink = const Color(0xFFFF2D65);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);
  bool isTimelineSelected = true;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<JournalHistoryViewModel>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    final userId = sessionProvider.userId ?? '';

    return Scaffold(
      backgroundColor: backgroundSoftPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryPink, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Journal History', style: TextStyle(color: Color(0xFF2E2E2E), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<JournalModel>>(
              stream: userId.isEmpty ? Stream.value([]) : viewModel.getJournalStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No journals found. Start writing!"));
                }

                final journals = snapshot.data!;
                // Sort by date descending
                journals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: journals.length,
                  itemBuilder: (context, index) {
                    final journal = journals[index];
                    return _buildJournalItem(journal);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalItem(JournalModel journal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Column(
            children: [
              Text(DateFormat('dd').format(journal.createdAt), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(DateFormat('MMM').format(journal.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 16),
          Text(journal.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(journal.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('${DateFormat('hh:mm a').format(journal.createdAt)} • Mood: ${journal.mood}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.withOpacity(0.3), size: 20),
            onPressed: () {
              final userId = Provider.of<SessionProvider>(context, listen: false).userId ?? '';
              Provider.of<JournalHistoryViewModel>(context, listen: false).deleteJournal(userId, journal.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 45,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => isTimelineSelected = true),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isTimelineSelected ? primaryPink : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Timeline', style: TextStyle(color: isTimelineSelected ? Colors.white : Colors.black54)),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const JournalCalendarViewScreen()));
                },
                child: Container(
                  alignment: Alignment.center,
                  child: const Text('Calendar', style: TextStyle(color: Colors.black54)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
