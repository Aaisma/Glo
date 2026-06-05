import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Visit Logger',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const LogVisitScreen(),
    );
  }
}

class LogVisitScreen extends StatefulWidget {
  const LogVisitScreen({super.key});

  @override
  State<LogVisitScreen> createState() => _LogVisitScreenState();
}

class _LogVisitScreenState extends State<LogVisitScreen> {
  final _dateController = TextEditingController();
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text("Log Visit"),
        backgroundColor: Colors.pink,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Record your doctor visit details",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // Date of Visit
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: "Date of Visit",
                  hintText: "Enter date (e.g. April 10, 2023)",
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.pink),
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              const SizedBox(height: 15),

              // Doctor's Name
              TextField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: "Doctor's Name",
                  hintText: "Enter doctor's name",
                  prefixIcon: Icon(Icons.person, color: Colors.pink),
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              const SizedBox(height: 15),

              // Visit Notes
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Visit Notes",
                  hintText: "Write your notes here...",
                  prefixIcon: Icon(Icons.note, color: Colors.pink),
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              const Spacer(),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VisitSavedScreen(
                          date: _dateController.text,
                          doctor: _doctorController.text,
                          notes: _notesController.text,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Save Visit",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VisitSavedScreen extends StatelessWidget {
  final String date;
  final String doctor;
  final String notes;

  const VisitSavedScreen({
    super.key,
    required this.date,
    required this.doctor,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visit Saved"),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: $date", style: const TextStyle(fontSize: 16)),
            Text("Doctor: $doctor", style: const TextStyle(fontSize: 16)),
            Text("Notes: $notes", style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
