import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodel/journal_history_viewmodel.dart';
import '../../model/journal_entry_model.dart';
import 'WriteJournalScreen.dart';

class JournalCalendarViewScreen extends StatefulWidget {
  const JournalCalendarViewScreen({Key? key}) : super(key: key);

  @override
  State<JournalCalendarViewScreen> createState() => _JournalCalendarViewScreenState();
}

class _JournalCalendarViewScreenState extends State<JournalCalendarViewScreen> {
  final Color primaryPink = const Color(0xFFFF2D65);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final historyVM = context.read<JournalHistoryViewModel>();
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
        title: Text(
          DateFormat('MMMM yyyy').format(_focusedDay),
          style: const TextStyle(color: Color(0xFF2E2E2E), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: userId.isEmpty
            ? const Center(child: Text("Please log in to view calendar."))
            : StreamBuilder<List<JournalEntryModel>>(
          stream: historyVM.getJournalStream(userId),
          builder: (context, snapshot) {
            final allJournals = snapshot.data ?? [];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildCalendar(allJournals),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildDayEntries(allJournals),
                  ),
                  _buildWriteButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendar(List<JournalEntryModel> allJournals) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() => _focusedDay = focusedDay);
        },
        headerVisible: false, // Custom header in AppBar
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: primaryPink.withOpacity(0.2), shape: BoxShape.circle),
          todayTextStyle: TextStyle(color: primaryPink, fontWeight: FontWeight.bold),
          selectedDecoration: BoxDecoration(color: primaryPink, shape: BoxShape.circle),
          markerDecoration: BoxDecoration(color: primaryPink, shape: BoxShape.circle),
          outsideDaysVisible: false,
        ),
        eventLoader: (day) {
          return allJournals.where((j) => isSameDay(j.createdAt, day)).toList();
        },
      ),
    );
  }

  Widget _buildDayEntries(List<JournalEntryModel> allJournals) {
    final dayJournals = allJournals.where((j) => isSameDay(j.createdAt, _selectedDay)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('MMMM dd, yyyy').format(_selectedDay!),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        if (dayJournals.isEmpty)
          const Expanded(
            child: Center(
              child: Text("No entries for this day.", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: dayJournals.length,
              itemBuilder: (context, index) {
                final journal = dayJournals[index];
                return _buildEntryCard(journal);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEntryCard(JournalEntryModel journal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Text(journal.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(journal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  '${DateFormat('hh:mm a').format(journal.createdAt)} • Mood: ${journal.mood}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildWriteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const WriteJournalScreen()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Add Journal Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}