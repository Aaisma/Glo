import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/meal_tracker_viewmodel.dart';
import '../app_colors.dart';

class NutritionHistoryScreen extends StatelessWidget {
  const NutritionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NutritionTrackerViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Nutrition History", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.pink,
        elevation: 0,
      ),
      body: vm.history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu_rounded, size: 80, color: AppColors.lightPink),
                  const SizedBox(height: 20),
                  Text("No history yet", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: vm.history.length,
              itemBuilder: (context, index) {
                final entry = vm.history[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardPink,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.borderPink),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.date,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.pink),
                          ),
                          Icon(Icons.check_circle_rounded, color: AppColors.pink.withOpacity(0.5), size: 20),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ...entry.meals.map((meal) {
                        final items = List<String>.from(meal["items"] ?? []);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${meal["type"]}: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Expanded(child: Text(items.join(", "), style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                        );
                      }).toList(),
                      if (entry.note.isNotEmpty) ...[
                        const Divider(height: 30),
                        Text("Note: ${entry.note}", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: AppColors.grey)),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
