import 'package:flutter/material.dart';

void main() {
  runApp(const Prescription());
}

class Prescription extends StatelessWidget {
  const Prescription({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prescription Manager',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const PrescriptionScreen(),
    );
  }
}

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescription"),
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
                "Manage your prescriptions efficiently",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                ),
                onPressed: () {
                  // Add prescription logic
                },
                child: const Text("+ Add Prescription"),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: [
                    PrescriptionCard(
                      icon: "assets/images/pill.png",
                      title: "Doxycycline 100mg",
                      subtitle: "1 capsule – Once Daily\nPrescribed by: Dr. Sarah Khan",
                      duration: "Apr 01, 2026 • Apr 15, 2026",
                    ),
                    PrescriptionCard(
                      icon: "assets/images/tablet.png",
                      title: "Hydrocortisone Cream",
                      subtitle: "Apply 2x Daily\nPrescribed by: Dr. Ahmed Ali",
                      duration: "Mar 20, 2026 • Apr 10, 2026",
                    ),
                    PrescriptionCard(
                      icon: "assets/images/pill.png",
                      title: "Vitamin D3",
                      subtitle: "1 tablet – After Breakfast\nPrescribed by: Dr. Sarah Khan",
                      duration: "Feb 10, 2026 • Mar 10, 2026",
                    ),
                  ],
                ),
              ),

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
                        builder: (context) => const PrescriptionSavedScreen(),
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

class PrescriptionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String duration;

  const PrescriptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white70,
      child: ListTile(
        leading: Image.asset(icon, width: 40, height: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$subtitle\n$duration"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrescriptionDetailScreen(
                title: title,
                subtitle: subtitle,
                duration: duration,
              ),
            ),
          );
        },
      ),
    );
  }
}

class PrescriptionDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;

  const PrescriptionDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prescription Detail"), backgroundColor: Colors.pink),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(subtitle, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Duration: $duration", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class PrescriptionSavedScreen extends StatelessWidget {
  const PrescriptionSavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved"), backgroundColor: Colors.pink),
      body: const Center(
        child: Text("Prescriptions saved successfully!", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
