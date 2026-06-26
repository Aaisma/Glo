import 'package:flutter/material.dart';

class MedicationHistoryScreen extends StatelessWidget {
  final String userId;

  const MedicationHistoryScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
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
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.pink),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Medication History",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.pink),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                "View your past medications 💊",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),

              const SizedBox(height: 20),

              /// FILTER TABS
              Row(
                children: [
                  filterChip("All", true),
                  const SizedBox(width: 8),
                  filterChip("Antibiotics", false),
                ],
              ),

              const SizedBox(height: 20),

              /// HISTORY CARDS
              historyCard(
                "assets/images/pill.png",
                "Amoxicillin 500mg",
                "Antibiotic",
                "1 capsule • 3 times a day",
                "Apr 01, 2022 - Apr 10, 2022",
              ),
              historyCard(
                "assets/images/tablet.png",
                "Calcium Supplement",
                "",
                "1 tablet • Daily",
                "Jan 15, 2022 - Feb 15, 2022",
              ),
              historyCard(
                "assets/images/cream.png",
                "Hydrocortisone Cream",
                "Topical",
                "Apply to affected area",
                "Nov 05, 2021 - Nov 15, 2022",
              ),
              historyCard(
                "assets/images/pill.png",
                "Ciprofloxacin 250mg",
                "Antibiotic",
                "1 tablet • Twice a day",
                "Sep 10, 2021 - Sep 20, 2021",
              ),
              historyCard(
                "assets/images/tablet.png",
                "Melatonin 5mg",
                "",
                "1 tablet • At Bedtime",
                "Aug 01, 2021 - Aug 20, 2021",
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  "That's all for now! 🌸",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper Widgets
  Widget filterChip(String label, bool selected) {
    return Container(
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
    );
  }

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    if (tag.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                              color: Colors.pink, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle),
                Text(duration, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}