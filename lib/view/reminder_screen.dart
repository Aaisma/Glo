import 'package:flutter/material.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  TimeOfDay time = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reminder")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Reminder Time: ${time.format(context)}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: time,
                );

                if (picked != null) {
                  setState(() => time = picked);
                }
              },
              child: const Text("Set Reminder"),
            ),
          ],
        ),
      ),
    );
  }
}