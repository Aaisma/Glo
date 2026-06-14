import 'package:flutter/material.dart';

import '../viewmodel/water_tracker_viewmodel.dart';
import '../repo/water_tracker_repo_impl.dart';

import 'edit_note_screen.dart';
import 'reminder_screen.dart';
import 'water_history_screen.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  late WaterTrackerViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = WaterTrackerViewModel(WaterTrackerRepoImpl());

    // Load data from Firebase
    viewModel.loadData().then((_) {
      setState(() {});
    });
  }

  void addWater(double amount) {
    viewModel.addWater(amount).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Tracker"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WaterHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReminderScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Current Intake",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      "${viewModel.currentIntake.toStringAsFixed(1)} L",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text("Daily Goal: ${viewModel.goal.toStringAsFixed(1)} L"),

                    const SizedBox(height: 8),

                    LinearProgressIndicator(
                      value: viewModel.currentIntake / viewModel.goal,
                      backgroundColor: Colors.grey[300],
                      color: Colors.lightBlueAccent,
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => addWater(0.1),
                          child: const Text("+100 ml"),
                        ),
                        ElevatedButton(
                          onPressed: () => addWater(0.25),
                          child: const Text("+250 ml"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),


            Card(
              child: ListTile(
                leading: const Icon(Icons.note, color: Colors.blue),
                title: const Text("Daily Notes"),
                subtitle: const Text("Tap to add or edit notes"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditNoteScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),


            Card(
              child: ListTile(
                leading: const Icon(Icons.water_drop, color: Colors.green),
                title: const Text("Water History"),
                subtitle: const Text("Check previous days intake"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WaterHistoryScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),


            Card(
              child: ListTile(
                leading:
                const Icon(Icons.notifications_active, color: Colors.orange),
                title: const Text("Reminder Settings"),
                subtitle: const Text("Set water drinking reminders"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReminderScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}