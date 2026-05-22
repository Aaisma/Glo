import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';

class OvulationPage extends StatefulWidget {
  const OvulationPage({super.key});

  @override
  State<OvulationPage> createState() => _OvulationPageState();
}

class _OvulationPageState extends State<OvulationPage> {
  NepaliDateTime? _selectedDateTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ovulation Calendar")),
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
                setState(() {});
              },
              child: const Text("Pick Ovulation Date"),
            ),
          ],
        ),
      ),
    );
  }
}
