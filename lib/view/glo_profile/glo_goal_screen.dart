import 'package:flutter/material.dart';

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "My Goal",
          style: TextStyle(
            color: Color(0xFFE573A0),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Stay consistent, feel my best & embrace every step.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Goal Overview
            _sectionTitle("Goal Overview"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _overviewCard("Current Cycle Day", "23", Icons.water_drop),
                _overviewCard("Cycle Length", "28 Days", Icons.loop),
              ],
            ),
            const SizedBox(height: 20),

            // Goal Progress
            _sectionTitle("Goal Progress"),
            _progressBar(23, 28),
            const SizedBox(height: 10),
            _progressStats(),
            const SizedBox(height: 20),

            // Goal Focus
            _sectionTitle("Goal Focus"),
            _focusCard("Stay Consistent", "Build a daily routine and stay on track", Icons.flag),
            _focusCard("Feel My Best", "Improve my mood, energy & overall well-being", Icons.favorite),
            _focusCard("Embrace Every Step", "Be kind to myself and enjoy the journey", Icons.directions_walk),
            const SizedBox(height: 20),

            // Milestones
            _sectionTitle("Milestones"),
            _milestone("First 7 Days", "Completed", "7 Days", "May 01, 2025"),
            _milestone("2 Weeks Strong", "Completed", "14 Days", "May 08, 2025"),
            _milestone("1 Month Goal", "In Progress", "28 Days", "May 22, 2025"),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Color(0xFFE573A0),
      ),
    ),
  );

  Widget _overviewCard(String label, String value, IconData icon) => Expanded(
    child: Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFE573A0), size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFE573A0))),
        ],
      ),
    ),
  );

  Widget _progressBar(int current, int total) {
    final progress = current / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          color: const Color(0xFFE573A0),
          backgroundColor: Colors.pink.shade50,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 6),
        Text("Progress This Cycle: $current / $total Days",
            style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _progressStats() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      _statItem(Icons.check_circle, "15 Days Logged"),
      _statItem(Icons.local_fire_department, "8 Day Streak"),
      _statItem(Icons.star, "3 Milestones"),
      _statItem(Icons.trending_up, "75% Completion"),
    ],
  );

  static Widget _statItem(IconData icon, String label) => Column(
    children: [
      Icon(icon, color: Color(0xFFE573A0)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.grey)),
    ],
  );

  Widget _focusCard(String title, String desc, IconData icon) => Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFFE573A0), size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE573A0))),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _milestone(String title, String status, String days, String date) =>
      Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE573A0))),
                Text("$status • $days • $date",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Icon(
              status == "Completed"
                  ? Icons.check_circle
                  : Icons.hourglass_bottom,
              color: status == "Completed"
                  ? const Color(0xFFE573A0)
                  : Colors.orangeAccent,
            ),
          ],
        ),
      );
}
