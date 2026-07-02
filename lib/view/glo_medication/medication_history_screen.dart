import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/model/medication_model.dart';
import 'package:glo/viewmodel/medication_viewmodel.dart';

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
              _header(context),
              const SizedBox(height: 8),
              const Text(
                "View your past medications 💊",
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              _filterTabs(),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<MedicationViewModel>(
                  builder: (context, viewModel, _) {
                    return StreamBuilder<List<MedicationModel>>(
                      stream: viewModel.fetchMedicationsStream(widget.userId),
                      builder: (context, snapshot) {
                        final meds =
                        snapshot.hasData && snapshot.data!.isNotEmpty
                            ? snapshot.data!
                            : fallbackMeds;

                        final filtered = meds.where((med) {
                          final medName = med.name ?? "";
                          final medType = med.type ?? "";

                          final matchesFilter = selectedFilter == "All" ||
                              (selectedFilter == "Antibiotics" &&
                                  medType == "Antibiotic");

                          final matchesSearch = searchQuery.isEmpty ||
                              medName
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase());

                          return matchesFilter && matchesSearch;
                        }).toList();

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final med = filtered[index];

                            return _historyCard(
                              image: _getMedicationImage(med.type),
                              title: med.name ?? "Unknown",
                              tag: med.type ?? "",
                              subtitle: med.dosage ?? "",
                              duration:
                              "${_formatDate(med.startDate)} - ${_formatDate(med.endDate)}",
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "That's all for now! 🌸",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
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
              "Medication History",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.pink),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _filterTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFilterChip("All"),
        const SizedBox(width: 8),
        _buildFilterChip("Antibiotics"),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String tempQuery = searchQuery;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Search Medications",
            style: TextStyle(
              fontFamily: 'Serif',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: TextField(
            decoration: InputDecoration(
              hintText: "Enter medication name",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Colors.pink.shade100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Colors.pink.shade100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.pink, width: 1.4),
              ),
            ),
            onChanged: (value) => tempQuery = value,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => searchQuery = tempQuery);
                Navigator.pop(context);
              },
              child: const Text(
                "Search",
                style: TextStyle(color: Colors.pink),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.pink),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    final selected = selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.pink : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.pink),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade100.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
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

  Widget _historyCard({
    required String image,
    required String title,
    required String tag,
    required String subtitle,
    required String duration,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Image.asset(image, height: 50, width: 50),
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
                const SizedBox(height: 6),
                if (tag.isNotEmpty)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.pink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black87),
                ),
                Text(
                  duration,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMedicationImage(String? type) {
    switch (type) {
      case "Tablet":
        return "assets/images/tablet.png";
      case "Capsule":
        return "assets/images/pill.png";
      case "Topical":
        return "assets/images/creamtube.png";
      default:
        return "assets/images/prescription.png";
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "";
    return date.toLocal().toString().split(' ').first;
  }

  BoxDecoration _cardDecoration({Color color = Colors.white}) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.9),
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
}