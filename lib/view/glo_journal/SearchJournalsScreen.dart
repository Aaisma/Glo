import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/journal_viewmodel.dart';
import '../../model/journal_model.dart';

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
    final viewModel = Provider.of<JournalViewModel>(context);

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search journals...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: primaryPink),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.cancel, color: Colors.grey),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryPink : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: StreamBuilder<List<JournalModel>>(
                stream: viewModel.getJournals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No journals found."));
                  }

                  final query = _searchController.text.toLowerCase();
                  final journals = snapshot.data!.where((journal) {
                    final titleMatch = journal.title.toLowerCase().contains(query);
                    final moodMatch = journal.mood.toLowerCase().contains(query);
                    final contentMatch = journal.content.toLowerCase().contains(query);

                    if (selectedFilter == 'Title') return titleMatch;
                    if (selectedFilter == 'Mood') return moodMatch;
                    if (selectedFilter == 'Content') return contentMatch;
                    
                    return titleMatch || moodMatch || contentMatch;
                  }).toList();

                  if (journals.isEmpty) {
                    return const Center(child: Text("No results match your search."));
                  }

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
      ),
    );
  }

  Widget _buildJournalItem(JournalModel journal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journal.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      DateFormat('MMMM dd, yyyy').format(journal.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    Text(
                      journal.mood,
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  journal.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
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
