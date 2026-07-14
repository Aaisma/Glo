import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:glo/viewmodel/admin_wellness_viewmodel.dart';
import 'package:glo/model/user_model_mood.dart';

class WellnessCalendarScreen extends StatefulWidget {
  const WellnessCalendarScreen({super.key});

  @override
  State<WellnessCalendarScreen> createState() => _WellnessCalendarScreenState();
}

class _WellnessCalendarScreenState extends State<WellnessCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminWellnessViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Wellness Calendar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<UserModelMood>>(
          stream: viewModel.getAllMoodLogs(),
          builder: (context, snapshot) {
            final allMoods = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCalendar(allMoods),
                  const SizedBox(height: 20),
                  _buildLogsSection(allMoods),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendar(List<UserModelMood> allMoods) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
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
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: Colors.pinkAccent, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Colors.pink, shape: BoxShape.circle),
          markerDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
        ),
        eventLoader: (day) {
          return allMoods.where((m) => isSameDay(m.date, day)).toList();
        },
      ),
    );
  }

  Widget _buildLogsSection(List<UserModelMood> allMoods) {
    final dayLogs = allMoods.where((m) => isSameDay(m.date, _selectedDay)).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Logs on ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (dayLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("No community logs for this day.", style: TextStyle(color: Colors.grey))),
            )
          else
            ...dayLogs.map((log) => _buildLogItem(log)),
        ],
      ),
    );
  }

  Widget _buildLogItem(UserModelMood log) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.pink.shade50,
        child: const Icon(Icons.person, color: Colors.pink, size: 20),
      ),
      title: Text("User ID: ${log.id.split('_').first}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text("Mood: ${log.moodType}"),
      trailing: Text(DateFormat('hh:mm a').format(log.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
    );
  }
}
