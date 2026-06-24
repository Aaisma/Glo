import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/medication_model.dart';
import '../viewmodel/medication_viewmodel.dart';

class MedicationHistoryScreen extends StatefulWidget {
  final String userId;

  const MedicationHistoryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MedicationHistoryScreen> createState() =>
      _MedicationHistoryScreenState();
}

class _MedicationHistoryScreenState extends State<MedicationHistoryScreen> {
  String searchQuery = "";
  String selectedFilter = "All";

  /// Fallback sample meds (always shown if Firestore is empty)
  final List<MedicationModel> fallbackMeds = [
    MedicationModel(
      id: "1",
      name: "Amoxicillin 500mg",
      type: "Antibiotic",
      dosage: "1 capsule • 3 times a day",
      startDate: DateTime(2022, 4, 1),
      endDate: DateTime(2022, 4, 10),
    ),
    MedicationModel(
      id: "2",
      name: "Calcium Supplement",
      type: "Tablet",
      dosage: "1 tablet • Daily",
      startDate: DateTime(2022, 1, 15),
      endDate: DateTime(2022, 2, 15),
    ),
    MedicationModel(
      id: "3",
      name: "Hydrocortisone Cream",
      type: "Topical",
      dosage: "Apply to affected area",
      startDate: DateTime(2021, 11, 5),
      endDate: DateTime(2021, 11, 15),
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
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
                      "Medication History",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.pink),
                      onPressed: () {
                        showSearchDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              const Text(
                "View your past medications 💊",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// FILTER TABS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildFilterChip("All"),
                  const SizedBox(width: 8),
                  buildFilterChip("Antibiotics"),
                ],
              ),

              const SizedBox(height: 20),

              /// STREAM BUILDER (MVVM + fallback)
              Expanded(
                child: Consumer<MedicationViewModel>(
                  builder: (context, viewModel, _) {
                    return StreamBuilder<List<MedicationModel>>(
                      stream: viewModel.fetchMedicationsStream(widget.userId),
                      builder: (context, snapshot) {
                        List<MedicationModel> meds = [];

                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          meds = snapshot.data!;
                        } else {
                          meds = fallbackMeds; // ✅ show sample meds if empty
                        }

                        // Apply filter + search
                        final filtered = meds.where((med) {
                          final matchesFilter = selectedFilter == "All" ||
                              (selectedFilter == "Antibiotics" &&
                                  med.type == "Antibiotic");
                          final matchesSearch = searchQuery.isEmpty ||
                              (med.name ?? "")
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase());
                          return matchesFilter && matchesSearch;
                        }).toList();

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final med = filtered[index];
                            return historyCard(
                              med.type == "Tablet"
                                  ? "assets/images/tablet.png"
                                  : med.type == "Capsule"
                                  ? "assets/images/pill.png"
                                  : med.type == "Topical"
                                  ? "assets/images/creamtube.png"
                                  : "assets/images/prescription.png",
                              med.name ?? "Unknown",
                              med.type ?? "",
                              med.dosage ?? "",
                              "${med.startDate?.toLocal().toString().split(' ').first ?? ''} - ${med.endDate?.toLocal().toString().split(' ').first ?? ''}",
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              const Text("That's all for now! 🌸",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  /// Search Dialog
  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String tempQuery = searchQuery;
        return AlertDialog(
          title: const Text("Search Medications"),
          content: TextField(
            decoration: const InputDecoration(
              hintText: "Enter medication name",
            ),
            onChanged: (value) {
              tempQuery = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  searchQuery = tempQuery;
                });
                Navigator.pop(context);
              },
              child: const Text("Search"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  /// Filter Chip Builder
  Widget buildFilterChip(String label) {
    final selected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.pink : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.pink),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.pink,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// History Card
  Widget historyCard(
      String image,
      String title,
      String tag,
      String subtitle,
      String duration,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade100.withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(image, height: 50, width: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    if (tag.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(tag,
                            style: const TextStyle(
                                color: Colors.pink, fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.black87)),
                Text(duration,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
