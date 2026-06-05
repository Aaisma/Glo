import 'package:flutter/material.dart';

void main() {
  runApp(const Glo());
}

// Root widget for your app
class Glo extends StatelessWidget {
  const Glo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glo',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const FollowUpReminderScreen(),
    );
  }
}

// Actual Follow-Up Reminder screen
class FollowUpReminderScreen extends StatelessWidget {
  const FollowUpReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Follow-Up Reminder"),
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
                "Next Appointment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Card(
                color: Colors.white70,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage("assets/images/profilepicture.png"),
                    radius: 25,
                  ),
                  title: const Text("Dr. Sarah Khan"),
                  subtitle: const Text("Skin & Hair Specialist\nApril 20, 2026 • 10:00 AM"),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RescheduleScreen()),
                      );
                    },
                    child: const Text("Reschedule"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ReminderScreen()),
                      );
                    },
                    child: const Text("Set Reminder"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                "Upcoming Visits",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: Image.asset("assets/images/Pill.png", width: 30),
                      title: const Text("April 28, 2026"),
                      subtitle: const Text("Dr. Ahmed Ali • 2:00 PM"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VisitDetailScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Image.asset("assets/images/Pill.png", width: 30),
                      title: const Text("May 8, 2026"),
                      subtitle: const Text("Dr. Seema Patel • 11:30 AM"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VisitDetailScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Image.asset("assets/images/Pill.png", width: 30),
                      title: const Text("May 18, 2026"),
                      subtitle: const Text("Dr. Sameer Roy"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VisitDetailScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CalendarScreen()),
                    );
                  },
                  child: const Text("View Calendar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder screens
class RescheduleScreen extends StatelessWidget {
  const RescheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Reschedule")), body: const Center(child: Text("Reschedule Appointment")));
  }
}

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Set Reminder")), body: const Center(child: Text("Reminder Settings")));
  }
}

class VisitDetailScreen extends StatelessWidget {
  const VisitDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Visit Detail")), body: const Center(child: Text("Visit Details Here")));
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Calendar")), body: const Center(child: Text("Calendar View")));
  }
}
