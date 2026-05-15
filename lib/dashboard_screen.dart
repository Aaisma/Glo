import 'package:flutter/material.dart';
import 'dashboard_screen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.pink,
        title: const Text("Good Morning Victoria ❤️"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("You’re in your GLO… in sync with your body."),
            const SizedBox(height: 20),

            // Cycle Day Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("DAY 23",
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink)),
                        SizedBox(height: 8),
                        Text("Ovulation in 2 Days"),
                        SizedBox(height: 4),
                        Text("April 03, 2026",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Icon(Icons.local_florist, size: 60, color: Colors.pink),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Feature Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildFeatureCard(context, Icons.book, "Daily Journal", '/daily_journal'),
                _buildFeatureCard(context, Icons.water_drop, "Water Tracker", '/water_tracker'),
                _buildFeatureCard(context, Icons.medical_services, "Medications", '/medication'),
                _buildFeatureCard(context, Icons.spa, "Skin Tracker", '/skin_tracker'),
                _buildFeatureCard(context, Icons.healing, "Exercise", '/exercise'),
                _buildFeatureCard(context, Icons.bedtime, "Sleep & Stress", '/sleep_stress'),
              ],
            ),
            const SizedBox(height: 20),

            const Text("Listen to your body, Trust your journey"),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text("Log Symptoms"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        onTap: (index) {},
      ),
    );
  }

  static Widget _buildFeatureCard(BuildContext context, IconData icon, String label, String route) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: Colors.pink),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
