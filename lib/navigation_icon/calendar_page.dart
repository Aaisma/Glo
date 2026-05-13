import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  NepaliDateTime? _selectedDateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nepali Calendar")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show selected date
            Text(
              _selectedDateTime != null
                  ? NepaliDateFormat("yyyy-MM-dd").format(_selectedDateTime!)
                  : "No date selected",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Button to open Nepali date picker
            ElevatedButton(
              onPressed: () async {
                _selectedDateTime = await showNepaliDatePicker(
                  context: context,
                  initialDate: NepaliDateTime.now(),
                  firstDate: NepaliDateTime(2000),
                  lastDate: NepaliDateTime(2090),
                );
                setState((){});
              },
              child: const Text("Pick Nepali Date"),
            ),
          ],
        ),
      ),
    );
  }
}
