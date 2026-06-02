import 'package:flutter/material.dart';

class DermaVisitPage extends StatefulWidget {
  const DermaVisitPage({super.key});

  @override
  State<DermaVisitPage> createState() => _DermaVisitPageState();
}

class _DermaVisitPageState extends State<DermaVisitPage> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> tools = [
    {"icon": Icons.note_add, "title": "Log Visit"},
    {"icon": Icons.medical_services, "title": "Prescription"},
    {"icon": Icons.track_changes, "title": "Treatment Tracker"},
    {"icon": Icons.alarm, "title": "Follow-Up Reminder"},
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Example navigation
    switch (index) {
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const VisitsPage()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const RecordsPage()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ProfilePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text("Derma Visit"),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Next Visit Reminder
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Next Visit Reminder",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pinkAccent)),
                    SizedBox(height: 8),
                    Text("April 10, 2026 at 10:30 AM",
                        style: TextStyle(fontSize: 16)),
                    Text("Dr. Sarah Khan",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    Text("Skin & Hair Specialist",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // My Derma Tools
            const Text("My Derma Tools",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tools.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 1.2),
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("${tools[index]['title']} clicked")));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tools[index]['icon'],
                            size: 40, color: Colors.pinkAccent),
                        const SizedBox(height: 8),
                        Text(tools[index]['title'],
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Skin Health Tip
            Card(
              color: Colors.pink[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Skin Health Tip:\nConsistency is key! Follow your treatment plan and stay hydrated.",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Visits"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Records"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ✅ All constructors now use super.key
class VisitsPage extends StatelessWidget {
  const VisitsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Visits")),
          body: const Center(child: Text("Visits Page")));
}

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Records")),
          body: const Center(child: Text("Records Page")));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(title: const Text("Profile")),
          body: const Center(child: Text("Profile Page")));
}
