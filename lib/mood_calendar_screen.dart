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

  // Author-free inspiring quotes
  final Map<String, String> _moodQuotes = {
    '😍': '"Enjoy the little things, for one day you may look back and realize they were the big things."',
    '😀': '"Joy is not in things; it is in us."',
    '😌': '"Peace is the liberty in tranquility."',
    '😐': '"Life is a balance of holding on and letting go."',
    '😢': '"The soul would have no rainbow had the eyes no tears."',
    '😡': '"For every minute you are angry you lose sixty seconds of happiness."',
    '✨': '"Every day brings new choices and new opportunities."',
  };

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Generates dynamic mood emojis to populate the calendar grid
  String _getMoodForDate(DateTime date) {
    final normalized = _normalizeDate(date);
    final List<String> moods = ['😀', '😌', '😍', '😢', '😡', '😐', '😌', '😀', '😍', '😢'];
    int index = (normalized.day + normalized.month) % moods.length;
    return moods[index];
  }

  // EXACT MATCH PASTEL COLORS: Gives that signature "soft glow circle" behind the emoji
  Color _getMoodColor(String emoji) {
    switch (emoji) {
      case '😍':
        return const Color(0xFFFFEAEA); // Soft glow red/pink
      case '😀':
        return const Color(0xFFFFF4D4); // Soft glow yellow/orange
      case '😌':
        return const Color(0xE3D1F0FF); // Soft glow sky blue
      case '😐':
        return const Color(0xFFECECEC); // Soft glow neutral grey
      case '😢':
        return const Color(0xFFEADBFF); // Soft glow purple
      case '😡':
        return const Color(0xFFFFD6D6); // Deep soft red
      default:
        return Colors.transparent;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final selectedEmoji = _selectedDay != null ? _getMoodForDate(_selectedDay!) : '✨';
    final dailyQuote = _moodQuotes[selectedEmoji] ?? _moodQuotes['✨']!;

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
              // --- Calendar Card View ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFCE4EC), width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
                    weekdayStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13),
                    weekendStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13),
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
                  rowHeight: 76, // Generous row space to fit everything beautifully without overlap
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) => _buildCell(day, Colors.black),
                    outsideBuilder: (context, day, focusedDay) => _buildCell(day, Colors.grey.shade400),
                    selectedBuilder: (context, day, focusedDay) {
                      // Hot-pink selection circle tracking line around your current day
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.pinkAccent, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildCell(day, Colors.black),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Beautiful Author-Free Quotes Card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _getMoodColor(selectedEmoji),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        selectedEmoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dailyQuote,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
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

  // Exact reproduction of your target design grid cell
  Widget _buildCell(DateTime day, Color textColor) {
    String emoji = _getMoodForDate(day);
    Color glowColor = _getMoodColor(emoji);

    return Container(
      // Adds thin divider grid lines separating cell blocks like your image
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 0.5),
          right: BorderSide(color: Colors.grey.shade100, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor
            ),
          ),
          const SizedBox(height: 4),
          // Colored round background capsule wrapping around the target emoji
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: glowColor,
              shape: BoxShape.circle,
              // Drop shadow to replicate that premium depth effect
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}