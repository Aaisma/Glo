import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/period_view_model.dart';
import '../../viewmodel/ovulation_view_model.dart';

class SymptomsHistoryPage extends StatelessWidget {
  const SymptomsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final periodViewModel = context.watch<PeriodViewModel>();
    final ovulationViewModel = context.watch<OvulationViewModel>();

    // Combine logs that have symptoms
    // Using a Map with date key to merge symptoms from both trackers if they exist for the same day
    final Map<String, Map<String, bool>> combinedSymptoms = {};
    final Map<String, DateTime> dateMap = {};

    for (var log in periodViewModel.logs) {
      if (log.symptoms.values.any((v) => v)) {
        final key = DateFormat('yyyy-MM-dd').format(log.date);
        combinedSymptoms[key] = Map.from(log.symptoms);
        dateMap[key] = log.date;
      }
    }

    for (var log in ovulationViewModel.logs) {
      if (log.symptoms.values.any((v) => v)) {
        final key = DateFormat('yyyy-MM-dd').format(log.date);
        if (combinedSymptoms.containsKey(key)) {
          combinedSymptoms[key]!.addAll(log.symptoms);
        } else {
          combinedSymptoms[key] = Map.from(log.symptoms);
          dateMap[key] = log.date;
        }
      }
    }

    final sortedKeys = combinedSymptoms.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF14181F)),
        title: const Text(
          "Symptoms History",
          style: TextStyle(
            color: Color(0xFF14181F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: sortedKeys.isEmpty
          ? const Center(child: Text("No symptoms logged yet.", style: TextStyle(color: Colors.black54)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final key = sortedKeys[index];
                final date = dateMap[key]!;
                final symptoms = combinedSymptoms[key]!;
                
                final activeSymptoms = symptoms.entries
                    .where((e) => e.value)
                    .map((e) {
                      final sKey = e.key;
                      if (sKey.contains('_')) {
                        return sKey.split('_').last;
                      }
                      return sKey;
                    })
                    .toList();

                if (activeSymptoms.isEmpty) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD6E2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM dd, yyyy').format(date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14181F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: activeSymptoms.map((symptom) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEAF1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            symptom,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE85D8A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
