import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/wellness_viewmodel.dart';
import 'package:glo/viewmodel/user_viewmodel.dart';

class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  // FIXED: Changed to 'final' to solve the private field lint warning
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime(2026, 1, 1);
  DateTime? _selectedDay;

  // Moods explicitly defined by their name and emoji
  final List<Map<String, String>> _moodDefinitions = [
    {'name': 'Amazing', 'emoji': '😍'},
    {'name': 'Happy', 'emoji': '😀'},
    {'name': 'Calm', 'emoji': '😌'},
    {'name': 'Neutral', 'emoji': '😐'},
    {'name': 'Sad', 'emoji': '😢'},
    {'name': 'Angry', 'emoji': '😡'},
  ];

  // Map tracking user logged moods
  final Map<DateTime, String> _userLoggedMoods = {
    DateTime(2026, 1, 1): '😍',
    DateTime(2026, 1, 2): '😢',
    DateTime(2026, 1, 3): '😡',
    DateTime(2026, 1, 4): '😐',
    DateTime(2026, 1, 5): '😐',
    DateTime(2026, 1, 6): '😀',
    DateTime(2026, 1, 7): '😍',
    DateTime(2026, 1, 8): '😢',
    DateTime(2026, 1, 9): '😀',
  };

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

  Color _getMoodColor(String emoji) {
    switch (emoji) {
      case '😍':
        return const Color(0xFFFFEAEA);
      case '😀':
        return const Color(0xFFFFF4D4);
      case '😌':
        return const Color(0xE3D1F0FF);
      case '😐':
        return const Color(0xFFECECEC);
      case '😢':
        return const Color(0xFFEADBFF);
      case '😡':
        return const Color(0xFFFFD6D6);
      default:
        return Colors.transparent;
    }
  }

  void _openMoodLoggingSheet(DateTime date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How are you feeling on ${date.day}/${date.month}?',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: _moodDefinitions.length,
                itemBuilder: (context, index) {
                  final mood = _moodDefinitions[index];
                  final emoji = mood['emoji']!;
                  final name = mood['name']!;

                  return InkWell(
                    onTap: () async {
                      setState(() {
                        _userLoggedMoods[_normalizeDate(date)] = emoji;
                      });
                      final user = Provider.of<UserViewModel>(context, listen: false).user;
                      if (user != null) {
                        try {
                          await Provider.of<WellnessViewModel>(context, listen: false).logMood(
                            userId: user.id,
                            mood: name,
                            note: '',
                            factors: [],
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save mood: $e')),
                          );
                        }
                      }
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        // FIXED: Using updated modern Flutter .withValues() method to avoid deprecation warnings
                        color: _getMoodColor(emoji).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.pink.shade50, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 6),
                          Text(
                            name,
                            // FIXED: Removed the undefined 'black70' parameter and invalid constant error
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserViewModel>(context, listen: false).user;
      if (user != null) {
        Provider.of<WellnessViewModel>(context, listen: false).initUserSync(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wellnessVM = Provider.of<WellnessViewModel>(context);

    // Populate calendar from Firestore logs
    final Map<DateTime, String> userLoggedMoods = Map.from(_userLoggedMoods);
    for (var log in wellnessVM.moodHistory) {
      final normalizedDate = _normalizeDate(log.date);
      String emoji = '✨';
      if (log.moodType == 'Amazing') emoji = '😍';
      else if (log.moodType == 'Happy') emoji = '😀';
      else if (log.moodType == 'Calm') emoji = '😌';
      else if (log.moodType == 'Neutral') emoji = '😐';
      else if (log.moodType == 'Sad') emoji = '😢';
      else if (log.moodType == 'Angry') emoji = '😡';
      userLoggedMoods[normalizedDate] = emoji;
    }

    final normalizedSelected = _selectedDay != null ? _normalizeDate(_selectedDay!) : null;
    final selectedEmoji = userLoggedMoods[normalizedSelected] ?? '✨';
    final dailyQuote = _moodQuotes[selectedEmoji] ?? _moodQuotes['✨']!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
              // --- Calendar View ---
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
                    _openMoodLoggingSheet(selectedDay);
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  rowHeight: 76,
                  calendarBuilders: CalendarBuilders(
                    // FIXED: Removed the invalid parameter 'weekendBuilder' completely
                    defaultBuilder: (context, day, focusedDay) => _buildCell(day, Colors.black, userLoggedMoods),
                    outsideBuilder: (context, day, focusedDay) => _buildCell(day, Colors.grey.shade400, userLoggedMoods),
                    selectedBuilder: (context, day, focusedDay) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.pinkAccent, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildCell(day, Colors.black, userLoggedMoods),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Dynamic Insight Quote Card ---
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

  Widget _buildCell(DateTime day, Color textColor, Map<DateTime, String> userLoggedMoods) {
    String? emoji = userLoggedMoods[_normalizeDate(day)];
    Color glowColor = emoji != null ? _getMoodColor(emoji) : Colors.transparent;

    return Container(
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: glowColor,
              shape: BoxShape.circle,
              boxShadow: emoji != null ? [
                BoxShadow(
                  // FIXED: Changed .withOpacity to modern .withValues() method
                  color: glowColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Text(
              emoji ?? '',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}


