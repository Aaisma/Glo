import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:glo/viewmodel/admin_wellness_viewmodel.dart';
import 'package:glo/model/journal_model.dart';

class JournalReviewScreen extends StatefulWidget {
  const JournalReviewScreen({super.key});

  @override
  State<JournalReviewScreen> createState() => _JournalReviewScreenState();
}

class _JournalReviewScreenState extends State<JournalReviewScreen> {
  @override
  Widget build(BuildContext context) {
    // Consistently using AdminWellnessViewModel for the Wellness module
    final viewModel = Provider.of<AdminWellnessViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Journal Review", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<JournalModel>>(
                stream: viewModel.getAllJournals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No journals to review.", style: TextStyle(color: Colors.grey))
                    );
                  }

                  final journals = snapshot.data!;
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: journals.length,
                    itemBuilder: (context, index) => _buildJournalCard(journals[index], viewModel),
                  );
                },
              ),
            ),
            _buildSummaryFooter(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCard(JournalModel journal, AdminWellnessViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.pink.shade50,
                child: Text(journal.emoji.isNotEmpty ? journal.emoji : "📝", style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(journal.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(journal.createdAt), 
                      style: const TextStyle(fontSize: 11, color: Colors.grey)
                    ),
                  ]
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(20)),
                child: Text(journal.mood, style: const TextStyle(fontSize: 10, color: Colors.pink, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(journal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2E2E2E))),
          const SizedBox(height: 6),
          Text(
            journal.content, 
            maxLines: 4, 
            overflow: TextOverflow.ellipsis, 
            style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5)
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Journal marked as reviewed! ✅")));
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ), 
                  child: const Text("Approve", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                )
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _confirmDelete(journal.id, viewModel), 
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id, AdminWellnessViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Entry?"),
        content: const Text("This action cannot be undone. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await viewModel.deleteJournal(id);
              if (mounted) Navigator.pop(context);
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryFooter(AdminWellnessViewModel viewModel) {
    return StreamBuilder<List<JournalModel>>(
      stream: viewModel.getAllJournals(),
      builder: (context, snapshot) {
        int count = snapshot.data?.length ?? 0;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, 
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              const Icon(Icons.analytics_outlined, color: Colors.purple, size: 36),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Journal Analytics", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                  Text("$count Active Entries", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.pinkAccent)),
                ]
              ),
            ],
          ),
        );
      }
    );
  }
}
