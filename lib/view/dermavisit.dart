import 'package:flutter/material.dart';

class DermaVisitScreen extends StatelessWidget {
  const DermaVisitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Derma Visit",
          style: TextStyle(
            color: Colors.pink,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manage your skin health journey with ease 💗",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Next Visit Reminder
            Card(
              color: Colors.pink[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text(
                  "Next Visit Reminder",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  "April 10, 2026 - 10:30 AM\nDr. Sarah Khan, Skin & Hair Specialist",
                  style: TextStyle(color: Colors.black87),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.pink),
              ),
            ),
            const SizedBox(height: 25),

            // My Derma Tools
            const Text(
              "My Derma Tools",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 10),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildToolCard(
                  context,
                  icon: Icons.calendar_today,
                  title: "Log Visit",
                  subtitle: "Record doctor visits",
                ),
                _buildToolCard(
                  context,
                  icon: Icons.medical_services,
                  title: "Prescription",
                  subtitle: "Store prescriptions",
                ),
                _buildToolCard(
                  context,
                  icon: Icons.spa,
                  title: "Treatment Tracker",
                  subtitle: "Track treatment progress",
                ),
                _buildToolCard(
                  context,
                  icon: Icons.alarm,
                  title: "Follow-Up Reminder",
                  subtitle: "Never miss appointments",
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Skin Health Tip
            Card(
              color: Colors.pink[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                leading: Icon(Icons.lightbulb, color: Colors.pink),
                title: Text(
                  "Consistency is key! Follow your treatment plan and stay hydrated.",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.pink[100],
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Visits"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Records"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context,
      {required IconData icon, required String title, required String subtitle}) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Navigating to $title...")),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.pink, size: 40),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
