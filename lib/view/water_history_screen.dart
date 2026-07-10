import 'package:flutter/material.dart';
import '../repo/water_history_repo_impl.dart';
import 'package:provider/provider.dart';
import '../viewmodel/water_tracker_viewmodel.dart';
import '../app_colors.dart';


class WaterHistoryScreen extends StatefulWidget {
  final String userId;
  const WaterHistoryScreen({super.key, required this.userId});

  @override
  State<WaterHistoryScreen> createState() => _WaterHistoryScreenState();
}

class _WaterHistoryScreenState extends State<WaterHistoryScreen> {

  final repo = WaterHistoryRepoImpl();
  List history = [];


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WaterTrackerViewModel>().loadToday(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WaterTrackerViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Hydration History", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.pink,
        elevation: 0,
      ),
      body: vm.history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop_outlined, size: 80, color: AppColors.lightPink),
                  const SizedBox(height: 20),
                  Text("No history logged yet", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: vm.history.length,
              itemBuilder: (context, index) {
                final entry = vm.history[index];
                final double progress = entry.goal == 0 ? 0 : (entry.intake / entry.goal).clamp(0.0, 1.0);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardPink,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.borderPink.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.pink)),
                          Text("${(progress * 100).toInt()}% Goal", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(Icons.local_drink_rounded, color: AppColors.pink.withOpacity(0.7), size: 20),
                          const SizedBox(width: 10),
                          Text("${entry.intake}L", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
                          const Text(" / ", style: TextStyle(color: AppColors.grey)),
                          Text("${entry.goal}L Goal", style: const TextStyle(fontSize: 14, color: AppColors.grey)),
                        ],
                      ),
                      if (entry.note.isNotEmpty) ...[
                        const Divider(height: 30),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Notes: ${entry.note}", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: AppColors.grey)),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
