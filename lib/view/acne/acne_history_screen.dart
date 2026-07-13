import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/acne_tracker_viewmodel.dart';
import '../../constants/app_colors.dart';

class AcneHistoryScreen extends StatelessWidget {
  const AcneHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AcneTrackerViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Skin Journey History", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.pink,
        elevation: 0,
      ),
      body: vm.history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.face_retouching_natural_outlined, size: 80, color: AppColors.lightPink),
                  const SizedBox(height: 20),
                  Text("No history yet. Start your journey! ✨", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
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
                          Text(entry.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.pink)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.pink.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Text(entry.severity, style: const TextStyle(color: AppColors.pink, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (entry.imagePath.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: entry.imagePath.startsWith('http')
                              ? Image.network(entry.imagePath, height: 150, width: double.infinity, fit: BoxFit.cover)
                              : Image.file(File(entry.imagePath), height: 150, width: double.infinity, fit: BoxFit.cover),
                        ),
                      const SizedBox(height: 15),
                      if (entry.checklist.isNotEmpty) ...[
                        const Text("Routine Done:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 5),
                        Text(entry.checklist.join(", "), style: const TextStyle(fontSize: 13, color: AppColors.grey)),
                        const SizedBox(height: 10),
                      ],
                      if (entry.note.isNotEmpty) ...[
                        const Text("Reflections:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 5),
                        Text(entry.note, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: AppColors.grey)),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
