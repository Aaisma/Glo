import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodel/journal_history_viewmodel.dart';
import '../../viewmodel/favorites_viewmodel.dart';
import '../../model/journal_entry_model.dart';
import 'JournalCalendarViewScreen.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({Key? key}) : super(key: key);

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  // screenshot color profile
  final Color primaryPink = const Color(0xFFFF4B78);
  final Color backgroundSoftPink = const Color(0xFFFFF9FA);
  bool isTimelineSelected = true;

  @override
  Widget build(BuildContext context) {
    final historyVM = context.read<JournalHistoryViewModel>();
    final favoritesVM = context.read<FavoritesViewModel>();
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: backgroundSoftPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryPink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Journal History',
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildToggleBar(),
            const SizedBox(height: 10),
            Expanded(
              child: userId.isEmpty
                  ? const Center(child: Text("Please log in to view history."))
                  : StreamBuilder<List<JournalEntryModel>>(
                stream: historyVM.getJournalStream(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: primaryPink));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No memories captured yet. ✍️",
                          style: TextStyle(color: Colors.grey)),
                    );
                  }

                  final journals = snapshot.data!;

                  // Group journals by monthYear
                  Map<String, List<JournalEntryModel>> grouped = {};
                  for (var j in journals) {
                    String monthYear = DateFormat('MMMM yyyy').format(j.createdAt);
                    if (!grouped.containsKey(monthYear)) grouped[monthYear] = [];
                    grouped[monthYear]!.add(j);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, index) {
                      String month = grouped.keys.elementAt(index);
                      return _buildMonthSection(month, grouped[month]!, favoritesVM);
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

  Widget _buildToggleBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFFDEEF1), // Light pink background from screenshot
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            _toggleItem('Timeline', isTimelineSelected, () {
              setState(() => isTimelineSelected = true);
            }),
            _toggleItem('Calendar', !isTimelineSelected, () {
              // Note: Set state then navigate to ensure highlight sync
              setState(() => isTimelineSelected = false);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JournalCalendarViewScreen())
              ).then((_) => setState(() => isTimelineSelected = true));
            }),
          ],
        ),
      ),
    );
  }

  Widget _toggleItem(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isSelected ? primaryPink : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              )
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSection(String month, List<JournalEntryModel> items, FavoritesViewModel favVM) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 12),
          child: Text(
              month,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87
              )
          ),
        ),
        ...items.map((item) => _buildJournalItem(item, favVM)).toList(),
      ],
    );
  }

  Widget _buildJournalItem(JournalEntryModel item, FavoritesViewModel favVM) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  DateFormat('dd').format(item.createdAt),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)
              ),
              Text(
                  DateFormat('MMM').format(item.createdAt),
                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)
              ),
            ],
          ),
          const SizedBox(width: 24), // Wide spacing from screenshot
          Text(item.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                    '${DateFormat('hh:mm a').format(item.createdAt)} • Mood: ${item.mood}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w400)
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
                item.isFavorite ? Icons.bookmark : Icons.bookmark_outline,
                color: primaryPink,
                size: 26
            ),
            onPressed: () => favVM.toggleFavorite(item),
          ),
        ],
      ),
    );
  }
}