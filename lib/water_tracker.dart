import 'package:flutter/material.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  double currentIntake = 1.2; // in liters
  double goal = 2.5; // daily goal in liters
  String nextReminder = "11:00 AM";

  void addWater(double amount) {
    setState(() {
      currentIntake += amount;
      if (currentIntake > goal) currentIntake = goal;
    });
  }

  void resetIntake() {
    setState(() {
      currentIntake = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Water Tracker"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              const Positioned(
                right: 10,
                top: 10,
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Intake section
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
                        "${currentIntake.toStringAsFixed(1)} L",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Daily Goal: ${goal.toStringAsFixed(1)} L"),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: currentIntake / goal,
                        backgroundColor: Colors.grey[300],
                        color: Colors.lightBlueAccent,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => addWater(0.1),
                            child: const Text("+ 100 ml"),
                          ),
                          ElevatedButton(
                            onPressed: () => addWater(0.25),
                            child: const Text("+ 250 ml"),
                          ),
                          ElevatedButton(
                            onPressed: resetIntake,
                            child: const Text("Reset"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Reminder section
              Card(
                color: Colors.lightBlue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.notifications_active, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "Reminder",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Next Reminder: $nextReminder",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Reminders: Every 1 Hour",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("Set Reminder"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Motivation section
              Card(
                color: Colors.yellow[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Motivation",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "\"Stay hydrated, stay happy! 💧🌞\"",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Believe in Yourself! ❤️",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Notes section
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Today's Notes",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Note: You've drunk ${currentIntake.toStringAsFixed(1)} L of water so far. Keep it up, you're doing great! 💪💦",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text("Edit Note"),
                      ),
                    ],
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
