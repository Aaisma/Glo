import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:glo/model/medication_model.dart';
import 'package:glo/viewmodel/medication_viewmodel.dart';
import 'medication_history_screen.dart';
import 'add_medication_screen.dart';

class MedicationScreen extends StatefulWidget {
  final String userId;

  const MedicationScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  bool remindersEnabled = true;

  final Map<String, bool> scheduleStatus = {
    "Doxycycline 100mg": false,
    "Vitamin D3": false,
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicationViewModel>().fetchMedications(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MedicationViewModel>();

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
                _header(context),
                const SizedBox(height: 8),
                const Text(
                  "Track your medicines and stay consistent ❤️",
                  style: TextStyle(color: Colors.black45, fontSize: 16),
                ),
                const SizedBox(height: 20),
                _todayScheduleCard(),
                const SizedBox(height: 20),
                _yourMedicationHeader(context),
                const SizedBox(height: 15),
                _medicationList(viewModel),
                const SizedBox(height: 15),
                _reminderCard(),
                const SizedBox(height: 15),
                _historyCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.pink,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            "Medications",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _todayScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Schedule",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                "April 03, 2026",
                style: TextStyle(color: Colors.pink),
              ),
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
    );
  }

  Widget _yourMedicationHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Your Medications",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffF8A5B8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddMedicationScreen(userId: widget.userId),
              ),
            );

            if (!context.mounted) return;

            context.read<MedicationViewModel>().fetchMedications(widget.userId);
          },
          child: const Text("+ Add New"),
        ),
      ],
    );
  }

  Widget _medicationList(MedicationViewModel viewModel) {
    return StreamBuilder<List<MedicationModel>>(
      stream: viewModel.fetchMedicationsStream(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.pink),
            ),
          );
        }

        if (snapshot.hasError) {
          return _emptyMessage("Error loading medications");
        }

        final meds = snapshot.data ?? [];

        if (meds.isEmpty) {
          return _emptyMessage("No medications added yet 💊");
        }

        return Column(
          children: meds.map((med) {
            return medicationCard(
              context,
              image: _getMedicationImage(med.type),
              title: med.name ?? "Unnamed",
              subtitle: "${med.dosage ?? ''} • ${med.instructions ?? ''}",
              tag: "Active",
              doctor: med.doctorName ?? "Doctor Unknown",
              duration:
              "${_formatDate(med.startDate)} – ${_formatDate(med.endDate)}",
            );
          }).toList(),
        );
      },
    );
  }

  Widget _emptyMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _reminderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(color: const Color(0xffFDE4EB)),
      child: Row(
        children: [
          Image.asset(
            "assets/images/reminder.png",
            height: 40,
            errorBuilder: (_, _, _) {
              return const Icon(
                Icons.notifications_active_outlined,
                color: Colors.pink,
                size: 40,
              );
            },
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Medication Reminders",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Never miss your dose"),
              ],
            ),
          ),
          Switch(
            value: remindersEnabled,
            activeTrackColor: Colors.pink,
            onChanged: (value) {
              setState(() => remindersEnabled = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _historyCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicationHistoryScreen(userId: widget.userId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Image.asset(
              "assets/images/historylog.png",
              height: 40,
              errorBuilder: (_, _, _) {
                return const Icon(
                  Icons.history_rounded,
                  color: Colors.pink,
                  size: 40,
                );
              },
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Medication History",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("View past medications"),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.pink,
              size: 18,
            ),
          ],
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

  Widget scheduleTile(
      bool completed,
      String time,
      String medicine,
      String note,
      ) {
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
                Text(
                  medicine,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(note, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _cleanType(String? type) {
    if (type == null) return "";

    return type
        .replaceAll("💊", "")
        .replaceAll("🟣", "")
        .replaceAll("🧴", "")
        .replaceAll("💉", "")
        .trim();
  }

  String _getMedicationImage(String? type) {
    final cleanType = _cleanType(type).toLowerCase();

    if (cleanType.contains("tablet")) {
      return "assets/images/tablet.png";
    }

    if (cleanType.contains("capsule")) {
      return "assets/images/pill.png";
    }

    if (cleanType.contains("topical")) {
      return "assets/images/creamtube.png";
    }

    return "assets/images/prescription.png";
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "";
    return date.toLocal().toString().split(' ').first;
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
        Image.asset(
          image,
          height: 60,
          width: 60,
          errorBuilder: (_, _, _) {
            return const Icon(
              Icons.medication_outlined,
              color: Colors.pink,
              size: 50,
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle),
              const SizedBox(height: 8),
              Text(
                "Prescribed by $doctor",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                duration,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(color: Colors.pink),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.pink,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
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
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text(
                        "Close",
                        style: TextStyle(color: Colors.pink),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
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