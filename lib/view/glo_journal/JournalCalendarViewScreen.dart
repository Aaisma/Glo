import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/journal_viewmodel.dart';
import '../../model/journal_model.dart';
import 'WriteJournalScreen.dart';

class JournalCalendarViewScreen extends StatefulWidget {
  const JournalCalendarViewScreen({Key? key}) : super(key: key);

  @override
  State<JournalCalendarViewScreen> createState() => _JournalCalendarViewScreenState();
}

class _JournalCalendarViewScreenState extends State<JournalCalendarViewScreen> {
  final Color primaryPink = const Color(0xFFFF2D65);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    
    // Find the first Monday before or on the 1st of the month
    int firstWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun
    DateTime startDateTime = firstDayOfMonth.subtract(Duration(days: firstWeekday - 1));
    
    // Find the last Sunday after or on the last day of the month
    int lastWeekday = lastDayOfMonth.weekday;
    DateTime endDateTime = lastDayOfMonth.add(Duration(days: 7 - lastWeekday));
    
    List<DateTime> days = [];
    for (int i = 0; i <= endDateTime.difference(startDateTime).inDays; i++) {
      days.add(startDateTime.add(Duration(days: i)));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<JournalViewModel>(context);
    final calendarDays = _getDaysInMonth(_focusedDate);

    return Scaffold(
      backgroundColor: backgroundSoftPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryPink, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: primaryPink, size: 16),
              onPressed: () => setState(() => _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1)),
            ),
            const SizedBox(width: 10),
            Text(
              DateFormat('MMMM yyyy').format(_focusedDate),
              style: const TextStyle(
                color: Color(0xFF2E2E2E),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: primaryPink, size: 16),
              onPressed: () => setState(() => _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1)),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<JournalModel>>(
          stream: viewModel.getJournals(),
          builder: (context, snapshot) {
            final journals = snapshot.data ?? [];
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: weekdays.map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: calendarDays.length,
                    itemBuilder: (context, index) {
                      DateTime date = calendarDays[index];
                      bool isCurrentMonth = date.month == _focusedDate.month;
                      bool isSelected = DateUtils.isSameDay(date, _selectedDate);
                      bool hasEntry = journals.any((j) => DateUtils.isSameDay(j.createdAt, date));

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? primaryPink : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: (!isSelected && hasEntry) ? primaryPink : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: (isSelected || hasEntry) ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : (hasEntry ? primaryPink : (isCurrentMonth ? Colors.black87 : Colors.black26)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _buildDayEntries(journals),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WriteJournalScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Write Journal',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildDayEntries(List<JournalModel> allJournals) {
    final dayJournals = allJournals.where((j) => DateUtils.isSameDay(j.createdAt, _selectedDate)).toList();

    if (dayJournals.isEmpty) {
      return const Center(
        child: Text(
          "No entries for this day.",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      itemCount: dayJournals.length,
      itemBuilder: (context, index) {
        final journal = dayJournals[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
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
                    Row(
                      children: [
                        Text(journal.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            journal.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('hh:mm a').format(journal.createdAt)} • Mood: ${journal.mood}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      journal.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.black87.withOpacity(0.8), height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 16, color: primaryPink),
                onPressed: () {
                   // Navigate to detail or edit if needed
                },
              )
            ],
          ),
        );
      },
    );
  }
}
