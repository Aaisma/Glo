import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:glo/model/health_model.dart';
import 'package:glo/viewmodel/health_viewmodel.dart';

class FollowUpReminderScreen extends StatefulWidget {
  final String userId;

  const FollowUpReminderScreen({
    super.key,
    this.userId = "test-user-001",
  });

  @override
  State<FollowUpReminderScreen> createState() => _FollowUpReminderScreenState();
}

class _FollowUpReminderScreenState extends State<FollowUpReminderScreen> {
  static const Color _pink = Color(0xFFFF7DA4);
  static const Color _dark = Color(0xFF24303F);
  static const Color _softPink = Color(0xFFFFEFF4);
  static const Color _pageBg = Color(0xFFFFF7F9);

  DateTime _selectedDate = DateTime(2026, 4, 20);
  String _selectedTime = "10:00 AM";
  String _selectedReminder = "1 day before";

  final List<String> _times = const [
    "9:00 AM",
    "10:00 AM",
    "11:30 AM",
    "2:00 PM",
    "3:30 PM",
    "5:00 PM",
  ];

  final List<String> _reminders = const [
    "30 minutes before",
    "1 hour before",
    "1 day before",
    "2 days before",
  ];

  String get _appointmentDate {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return "${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year} at $_selectedTime";
  }

  Future<void> _saveReminderToFirebase(HealthViewModel viewModel) async {
    final item = HealthModel(
      userId: widget.userId,
      title: "Follow-Up Reminder",
      description: _appointmentDate,
      doctorName: "Dr. Sarah Khan",
      notes: _selectedReminder,
      followUpDate: _selectedDate,
    );

    await viewModel.addHealthItem(
      item,
      widget.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background1.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBackButton(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Follow-Up Reminder",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: _dark,
                              fontFamily: 'Serif',
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Manage your upcoming appointments\nand never miss your follow-up ♡",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _nextAppointmentCard(),
                          const SizedBox(height: 25),
                          const Text(
                            "Upcoming Visits",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _dark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _visitTile(
                            "Dr. Ahmed Ali",
                            "April 28, 2026 • 2:00 PM",
                          ),
                          const SizedBox(height: 14),
                          _visitTile(
                            "Dr. Seema Patel",
                            "May 8, 2026 • 11:30 AM",
                          ),
                          const SizedBox(height: 14),
                          _visitTile(
                            "Dr. Sameer Roy",
                            "May 18, 2026 • 3:00 PM",
                          ),
                          const SizedBox(height: 30),
                          _calendarButton(),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _circleButton(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => Navigator.pop(context),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: _pink, size: 18),
        onPressed: onTap,
      ),
    );
  }

  Widget _nextAppointmentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.calendar_month_rounded),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Next Visit Reminder",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _dark,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Dr. Sarah Khan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _dark,
                      ),
                    ),
                    Text(
                      "Skin & Hair Specialist",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: _pink,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _softPink,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: _pink,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _appointmentDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _dark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _smallButton(
                  text: "Reschedule",
                  onTap: () => _openDialog("Reschedule Appointment"),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _smallButton(
                  text: "Set Reminder",
                  onTap: () => _openDialog("Set Reminder"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _visitTile(String name, String date) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _showVisitDetails(name, date),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            _iconBox(Icons.person_outline_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showVisitDetails(name, date),
              icon: const Icon(
                Icons.event_available_outlined,
                color: _pink,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendarButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: InkWell(
        onTap: _showCalendarPopup,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF97B8), _pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "View Calendar",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 46,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: _pink,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.pink.withValues(alpha: 0.22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45),
          ),
        ),
        child: FittedBox(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        color: _softPink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: _pink, size: 30),
    );
  }

  void _showVisitDetails(String name, String date) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _pageBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          name,
          style: const TextStyle(
            color: _dark,
            fontWeight: FontWeight.w700,
            fontFamily: 'Serif',
          ),
        ),
        content: Text(
          "Appointment time:\n$date",
          style: const TextStyle(
            color: _dark,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: _pink)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _openDialog("Reschedule Visit");
            },
            style: FilledButton.styleFrom(backgroundColor: _pink),
            child: const Text("Reschedule"),
          ),
        ],
      ),
    );
  }

  void _openDialog(String title) {
    DateTime tempDate = _selectedDate;
    String tempTime = _selectedTime;
    String tempReminder = _selectedReminder;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (dialogContext, modalSetState) {
            return AlertDialog(
              backgroundColor: _pageBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _dark,
                  fontFamily: 'Serif',
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Choose Date",
                        style: TextStyle(
                          color: _dark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      CalendarDatePicker(
                        initialDate: tempDate.isBefore(DateTime.now())
                            ? DateTime.now()
                            : tempDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2027, 12, 31),
                        onDateChanged: (date) {
                          modalSetState(() => tempDate = date);
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Available Times",
                        style: TextStyle(
                          color: _dark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _times.map((time) {
                          final selected = tempTime == time;

                          return ChoiceChip(
                            label: Text(time),
                            selected: selected,
                            showCheckmark: false,
                            selectedColor: _pink.withValues(alpha: .22),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: selected
                                  ? _pink
                                  : _pink.withValues(alpha: .18),
                            ),
                            labelStyle: TextStyle(
                              color: selected ? _pink : _dark,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) {
                              modalSetState(() => tempTime = time);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "Reminder Settings",
                        style: TextStyle(
                          color: _dark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RadioGroup<String>(
                        groupValue: tempReminder,
                        onChanged: (value) {
                          if (value == null) return;
                          modalSetState(() => tempReminder = value);
                        },
                        child: Column(
                          children: _reminders.map((reminder) {
                            return RadioListTile<String>(
                              value: reminder,
                              activeColor: _pink,
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                reminder,
                                style: const TextStyle(
                                  color: _dark,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: _pink),
                  ),
                ),
                FilledButton(
                  onPressed: () async {
                    final navigator = Navigator.of(dialogContext);
                    final messenger = ScaffoldMessenger.of(dialogContext);
                    final viewModel = context.read<HealthViewModel>();

                    setState(() {
                      _selectedDate = tempDate;
                      _selectedTime = tempTime;
                      _selectedReminder = tempReminder;
                    });

                    await _saveReminderToFirebase(viewModel);

                    if (!mounted) return;

                    navigator.pop();

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          "Appointment updated. Reminder set $_selectedReminder.",
                        ),
                        backgroundColor: _pink,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(backgroundColor: _pink),
                  child: const Text("Save Changes"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCalendarPopup() {
    _openDialog("View Calendar");
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}