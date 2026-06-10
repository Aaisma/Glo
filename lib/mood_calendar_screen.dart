import 'package:flutter/material.dart';
import "package:table_calendar/table_calendar.dart";
import 'mood_entry_screen.dart';

class MoodCalendarScreen extends StatefulWidget {
  @override
  _MoodCalendarScreenState createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood Calendar 🌸")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MoodEntryScreen(date: selectedDay),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
