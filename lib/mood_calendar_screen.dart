import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime(2026, 1, 1);
  DateTime? _selectedDay;

  // Mock data mapping specific dates to mood emojis (2026 - 2036)
  final Map<DateTime, String> _moodData = {
    DateTime(2026, 5, 1): '😀',
    DateTime(2026, 5, 2): '😌',
    DateTime(2026, 5, 3): '😍',
    DateTime(2026, 5, 4): '😢',
    DateTime(2026, 5, 5): '😡',
    DateTime(2026, 5, 6): '😌',
    DateTime(2026, 5, 7): '😀',
    DateTime(2026, 5, 8): '😐',
    DateTime(2026, 5, 9): '😍',
  };

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Mood Calendar',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Calendar View Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.pink.shade50, width: 1),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: TableCalendar(
                  firstDay: DateTime(2026, 1, 1),
                  lastDay: DateTime(2036, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.pinkAccent),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.pinkAccent),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                    weekendStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  rowHeight: 65,
                  calendarBuilders: CalendarBuilders(
                    // Default builder correctly handles both weekdays and weekends
                    defaultBuilder: (context, day, focusedDay) => _buildCell(day, Colors.black),
                    outsideBuilder: (context, day, focusedDay) => _buildCell(day, Colors.grey.shade400),
                    selectedBuilder: (context, day, focusedDay) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.pinkAccent, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildCell(day, Colors.black),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Mood Legend Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mood Legend',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      children: [
                        _buildLegendItem('😍', 'Amazing'),
                        _buildLegendItem('😀', 'Happy'),
                        _buildLegendItem('😌', 'Calm'),
                        _buildLegendItem('😐', 'Neutral'),
                        _buildLegendItem('😢', 'Sad'),
                        _buildLegendItem('😡', 'Angry'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(DateTime day, Color textColor) {
    String? emoji = _moodData[_normalizeDate(day)];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${day.day}',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
        ),
        const SizedBox(height: 4),
        if (emoji != null)
          Text(emoji, style: const TextStyle(fontSize: 22))
        else
          const SizedBox(height: 26),
      ],
    );
  }

  Widget _buildLegendItem(String emoji, String label) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}