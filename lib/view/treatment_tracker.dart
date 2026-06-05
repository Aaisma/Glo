import 'package:flutter/material.dart';

void main() {
  runApp(const TreatmentTracker());
}

class TreatmentTracker extends StatelessWidget {
  const TreatmentTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treatment Tracker',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const TreatmentTrackerScreen(),
    );
  }
}

class TreatmentTrackerScreen extends StatefulWidget {
  const TreatmentTrackerScreen({super.key});

  @override
  State<TreatmentTrackerScreen> createState() => _TreatmentTrackerScreenState();
}

class _TreatmentTrackerScreenState extends State<TreatmentTrackerScreen> {
  double progress = 0.45; // 45% completion

  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final dateController = TextEditingController();
        final notesController = TextEditingController();

        return AlertDialog(
          title: const Text("Log Daily Entry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: "Date",
                  hintText: "Select date",
                ),
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: "Notes",
                  hintText: "Enter details...",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () {
                // Save entry logic here
                Navigator.pop(context);
              },
              child: const Text("Save Entry"),
            ),
          ],
        );
      },
    );
  }

  void _showAddPhotoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Photo"),
          content: const Text("Here you can attach a progress photo."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () {
                // Photo upload logic here
                Navigator.pop(context);
              },
              child: const Text("Upload"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Treatment Tracker"),
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
            children: [
              const Text(
                "Track your skin treatment progress",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Progress bar
              LinearProgressIndicator(
                value: progress,
                color: Colors.pink,
                backgroundColor: Colors.white70,
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    onPressed: _showAddEntryDialog,
                    child: const Text("+ Add Entry"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    onPressed: _showAddPhotoDialog,
                    child: const Text("+ Add Photo"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Daily Logs (example entries)
              Expanded(
                child: ListView(
                  children: const [
                    ListTile(
                      leading: Icon(Icons.medication, color: Colors.pink),
                      title: Text("April 5, 2026"),
                      subtitle: Text("Mild redness, applied cream before bed."),
                    ),
                    ListTile(
                      leading: Icon(Icons.photo, color: Colors.pink),
                      title: Text("April 4, 2026"),
                      subtitle: Text("Skin felt less irritated, took a progress selfie."),
                    ),
                    ListTile(
                      leading: Icon(Icons.medical_services, color: Colors.pink),
                      title: Text("April 3, 2026"),
                      subtitle: Text("Noticed some flaking. Started a new moisturizer."),
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
}
