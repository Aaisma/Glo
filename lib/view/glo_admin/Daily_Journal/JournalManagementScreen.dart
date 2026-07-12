import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:glo/viewmodel/admin_journal_viewmodel.dart';
import 'package:glo/model/journal_model.dart';

class JournalManagementScreen extends StatefulWidget {
  const JournalManagementScreen({super.key});

  @override
  State<JournalManagementScreen> createState() => _JournalManagementScreenState();
}

class _JournalManagementScreenState extends State<JournalManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "All";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accessing the Admin Journal ViewModel
    final viewModel = Provider.of<AdminJournalViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: "Search Journals by title, author, mood...",
                    prefixIcon: Icon(Icons.search, color: Colors.pinkAccent),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            _buildFilters(),
            Expanded(
              child: StreamBuilder<List<JournalModel>>(
                stream: viewModel.getAllJournals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No journals found."));
                  }

                  final query = _searchController.text.toLowerCase();
                  final journals = snapshot.data!.where((journal) {
                    final matchesQuery = journal.title.toLowerCase().contains(query) ||
                        journal.userName.toLowerCase().contains(query) ||
                        journal.mood.toLowerCase().contains(query);

                    if (_selectedFilter == "All") return matchesQuery;
                    if (_selectedFilter == "Today") {
                      return matchesQuery && DateUtils.isSameDay(journal.createdAt, DateTime.now());
                    }
                    if (_selectedFilter == "This Week") {
                      final now = DateTime.now();
                      final weekAgo = now.subtract(const Duration(days: 7));
                      return matchesQuery && journal.createdAt.isAfter(weekAgo);
                    }
                    return matchesQuery;
                  }).toList();

                  // Sort by most recent first
                  journals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: journals.length,
                    itemBuilder: (context, index) => _JournalItem(
                      journal: journals[index],
                      onDelete: () => _confirmDelete(context, viewModel, journals[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminJournalViewModel viewModel, JournalModel journal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Journal"),
        content: Text("Are you sure you want to delete '${journal.title}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              viewModel.deleteJournal(journal.id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text("Journal Management", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Spacer(),
          const Icon(Icons.notifications_none),
          const SizedBox(width: 15),
          const Icon(Icons.filter_list),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _filterChip("All"),
          _filterChip("Today"),
          _filterChip("This Week"),
          const Icon(Icons.calendar_today, size: 20),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pinkAccent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.pinkAccent : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12),
        ),
      ),
    );
  }
}

class _JournalItem extends StatelessWidget {
  final JournalModel journal;
  final VoidCallback onDelete;

  const _JournalItem({required this.journal, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFDE7E7),
            child: Text(journal.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(journal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "by ${journal.userName} • ${DateFormat('MMM dd, yyyy').format(journal.createdAt)}",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(Icons.emoji_emotions, color: Colors.orange, size: 20),
              Text(journal.mood, style: const TextStyle(fontSize: 9)),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view', child: Text("View Details")),
              const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}
