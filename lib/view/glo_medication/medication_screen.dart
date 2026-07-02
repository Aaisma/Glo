import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/model/medication_model.dart';
import 'package:glo/viewmodel/medication_viewmodel.dart';
import 'medication_history_screen.dart';
import 'add_medication_screen.dart';

class MedicationScreen extends StatefulWidget {
  final String userId;

  const MedicationScreen({super.key, required this.userId});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  bool remindersEnabled = true;
  Map<String, bool> scheduleStatus = {
    "Doxycycline 100mg": false,
    "Vitamin D3": false,
  };

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MedicationViewModel>(context);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background1.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.pink),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Medications",
                      style: TextStyle(
                          fontFamily: 'Serif',
                          fontSize: 35,  fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Track your medicines and stay consistent ❤️",
                  style: TextStyle(color: Colors.black45, fontSize: 16),
                ),

                const SizedBox(height: 20),

                /// TODAY'S SCHEDULE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
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
                      scheduleTile(
                        scheduleStatus["Doxycycline 100mg"] ?? false,
                        "08:00 AM",
                        "Doxycycline 100mg",
                        "1 capsule after breakfast",
                      ),
                      const Divider(),
                      scheduleTile(
                        scheduleStatus["Vitamin D3"] ?? false,
                        "08:00 PM",
                        "Vitamin D3",
                        "1 tablet after dinner",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// HEADER + ADD NEW BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Your Medications",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffF8A5B8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddMedicationScreen(userId: widget.userId),
                          ),
                        );
                      },
                      child: const Text("+ Add New"),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                /// MEDICATION LIST (Firestore stream + default Vitamin D3)
                StreamBuilder<List<MedicationModel>>(
                  stream: viewModel.fetchMedicationsStream(widget.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Colors.pink));
                    }
                    final meds = snapshot.data ?? [];
                    if (meds.isEmpty) {
                      // Show default Vitamin D3 card instead of empty text
                      return medicationCard(
                        context,
                        image: "assets/images/pill.png",
                        title: "Vitamin D3",
                        subtitle: "1 tablet • After Dinner",
                        tag: "Active",
                        doctor: "Dr. Sarah Khan",
                        duration: "Apr 01, 2026 – Apr 30, 2026",
                      );
                    }
                    return Column(
                      children: meds
                          .map((med) => medicationCard(
                        context,
                        image: "assets/images/pill.png",
                        title: med.name ?? "Unnamed",
                        subtitle:
                        "${med.dosage ?? ''} • ${med.instructions ?? ''}",
                        tag: "Active",
                        doctor: med.doctorName ?? "Doctor Unknown",
                        duration:
                        "${med.startDate?.toLocal().toString().split(' ').first ?? ''} – ${med.endDate?.toLocal().toString().split(' ').first ?? ''}",
                      ))
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 15),

                /// REMINDER CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(color: const Color(0xffFDE4EB)),
                  child: Row(
                    children: [
                      Image.asset("assets/images/reminder.png",
                          height: 40),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Medication Reminders",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text("Never miss your dose"),
                          ],
                        ),
                      ),
                      Switch(
                        value: remindersEnabled,
                        activeTrackColor: Colors.pink,
                        onChanged: (value) {
                          setState(() {
                            remindersEnabled = value;
                          });
                          debugPrint("Reminders: $value");
                        },
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
                        builder: (_) =>
                            MedicationHistoryScreen(userId: widget.userId),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Row(
                      children: [
                        Image.asset("assets/images/historylog.png",
                            height: 40),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Medication History",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  BoxDecoration _cardDecoration({Color color = Colors.white}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.shade100.withValues(alpha: 0.4),
          blurRadius: 8,
          offset: const Offset(2, 4),
        ),
      ],
    );
  }

  Widget scheduleTile(bool completed, String time, String medicine, String note) {
    return InkWell(
      onTap: () {
        setState(() {
          scheduleStatus[medicine] = !(scheduleStatus[medicine] ?? false);
        });
      },
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : Colors.pink,
          ),
          const SizedBox(width: 12),
          Text(time),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicine,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(note, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget medicationCard(
    BuildContext context, {
      required String image,
      required String title,
      required String subtitle,
      required String tag,
      required String doctor,
      required String duration,
    }) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.shade100.withValues(alpha: 0.4),
          blurRadius: 8,
          offset: const Offset(2, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Image.asset(image, height: 60, width: 60),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle),
              const SizedBox(height: 8),
              Text("Prescribed by $doctor",
                  style: const TextStyle(color: Colors.grey)),
              Text(duration,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tag,
                    style: const TextStyle(color: Colors.pink)),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios,
              size: 18, color: Colors.pink),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.pink)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Details: $subtitle"),
                      const SizedBox(height: 8),
                      Text("Prescribed by: $doctor"),
                      const SizedBox(height: 8),
                      Text("Duration: $duration"),
                      const SizedBox(height: 8),
                      Text("Status: $tag"),
                      const SizedBox(height: 12),
                      const Text(
                        "Description:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Vitamin D3 helps your body absorb calcium and maintain strong bones. "
                            "It is usually taken after meals to improve absorption.",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Close",
                          style: TextStyle(color: Colors.pink)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    ),
  );
}

