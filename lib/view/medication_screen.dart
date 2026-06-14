import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/model/medication_model.dart';
import '../viewmodel/medication_viewmodel.dart';
import 'medication_history_screen.dart';

class MedicationScreen extends StatelessWidget {
  final String userId; // pass logged-in userId from Firebase Auth

  const MedicationScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MedicationViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Medications",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Track your medicines and stay consistent 💗",
                style: TextStyle(color: Colors.black45, fontSize: 18),
              ),

              const SizedBox(height: 20),

              /// TODAY'S SCHEDULE (static demo)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Today's Schedule",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        Text("April 03, 2026",
                            style: TextStyle(color: Colors.pink)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    scheduleTile(true, "08:00 AM", "Doxycycline 100mg",
                        "1 capsule after breakfast"),
                    const Divider(),
                    scheduleTile(false, "08:00 PM", "Vitamin D3",
                        "1 tablet after dinner"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// MEDICATION HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Your Medications",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffF8A5B8),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // TODO: Navigate to AddMedicationScreen
                    },
                    child: const Text("+ Add New"),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              /// MEDICATION LIST (dynamic from Firestore)
              StreamBuilder<List<Medication>>(
                stream: viewModel.fetchMedications(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  final meds = snapshot.data ?? [];
                  if (meds.isEmpty) {
                    return const Text("No medications found.");
                  }
                  return Column(
                    children: meds
                        .map((med) => medicationCard(
                      context,
                      image: "assets/images/pill.png",
                      title: med.name,
                      subtitle: "${med.dosage} • ${med.instructions}",
                      tag: "Active",
                      doctor: "Doctor Unknown",
                      duration:
                      "${med.startDate.toLocal()} – ${med.endDate.toLocal()}",
                    ))
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 15),

              /// REMINDER CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffFDE4EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Image.asset("assets/images/reminder.png", height: 40),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Medication Reminders",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Never miss your dose"),
                        ],
                      ),
                    ),
                    Switch(
                      value: true,
                      activeTrackColor: Colors.pink.shade200,
                      activeThumbColor: Colors.pink,
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// HISTORY CARD
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MedicationHistoryScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/historylog.png", height: 40),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Medication History",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("View past medications"),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.pink, size: 18),
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

/// Helper widgets
Widget scheduleTile(bool completed, String time, String medicine, String note) {
  return Row(
    children: [
      Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? Colors.green : Colors.pink),
      const SizedBox(width: 12),
      Text(time),
      const SizedBox(width: 15),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(medicine, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(note, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    ],
  );
}

Widget medicationCard(BuildContext context,
    {required String image,
      required String title,
      required String subtitle,
      required String tag,
      required String doctor,
      required String duration}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Image.asset(image, height: 60, width: 60),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle),
              const SizedBox(height: 8),
              Text("Prescribed by $doctor",
                  style: const TextStyle(color: Colors.grey)),
              Text(duration, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tag, style: const TextStyle(color: Colors.pink)),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.pink),
      ],
    ),
  );
}

/// HISTORY SCREEN
class MedicationHistoryScreen extends StatelessWidget {
  const MedicationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medication History")),
      body: const Center(child: Text("Past medication records appear here")),
    );
  }
}
