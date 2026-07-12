import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodel/search_journals_viewmodel.dart';
import '../../viewmodel/journal_history_viewmodel.dart';
import '../../model/journal_entry_model.dart';

class SearchJournalsScreen extends StatefulWidget {
  const SearchJournalsScreen({Key? key}) : super(key: key);

  @override
  State<SearchJournalsScreen> createState() => _SearchJournalsScreenState();
}

class _SearchJournalsScreenState extends State<SearchJournalsScreen> {
  final Color primaryPink = const Color(0xFFFF2D65);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Title', 'Mood', 'Content'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchVM = context.watch<SearchJournalsViewModel>();
    final historyVM = context.read<JournalHistoryViewModel>();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
          'Search Journals',
          style: TextStyle(color: Color(0xFF2E2E2E), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(searchVM, userId),
            _buildFilterChips(),
            Expanded(
              child: StreamBuilder<List<JournalEntryModel>>(
                stream: historyVM.getJournalStream(userId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // Sync the latest journals to the search viewmodel
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      searchVM.updateJournals(snapshot.data!);
                    });
                  }

                  if (searchVM.filteredJournals.isEmpty) {
                    return const Center(child: Text("No journals match your search."));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: searchVM.filteredJournals.length,
                    itemBuilder: (context, index) {
                      return _buildJournalItem(searchVM.filteredJournals[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(SearchJournalsViewModel searchVM, String userId) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: TextField(
          controller: _searchController,
          onChanged: (query) => searchVM.searchJournals(userId, query),
          decoration: InputDecoration(
            hintText: 'Search journals...',
            prefixIcon: Icon(Icons.search, color: primaryPink),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: isSelected ? primaryPink : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 13)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJournalItem(JournalEntryModel journal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(journal.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  '${DateFormat('MMM dd, yyyy').format(journal.createdAt)} • ${journal.mood}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(journal.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87.withOpacity(0.7))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(journal.emoji, style: const TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}
