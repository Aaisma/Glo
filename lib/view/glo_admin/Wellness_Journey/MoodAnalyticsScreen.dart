import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/admin_wellness_viewmodel.dart';
import 'package:glo/model/user_model_mood.dart';

class MoodAnalyticsScreen extends StatefulWidget {
  const MoodAnalyticsScreen({super.key});

  @override
  State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
}

class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminWellnessViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: StreamBuilder<List<UserModelMood>>(
          stream: viewModel.getAllMoodLogs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allLogs = snapshot.data ?? [];
            Map<String, int> moodCounts = {};
            Map<String, int> factorCounts = {};

            for (var log in allLogs) {
              moodCounts[log.moodType] = (moodCounts[log.moodType] ?? 0) + 1;
              for (var factor in log.factors) {
                factorCounts[factor] = (factorCounts[factor] ?? 0) + 1;
              }
            }

            // Sort factors by frequency
            var sortedFactors = factorCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildDonutChartSection(allLogs.length, moodCounts),
                  const SizedBox(height: 20),
                  _buildSymptomsSection(sortedFactors, allLogs.length),
                  const SizedBox(height: 20),
                  _buildFooter(allLogs.length),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const Text("Mood Analytics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Icon(Icons.calendar_month),
      ],
    );
  }

  Widget _buildDonutChartSection(int total, Map<String, int> counts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mood Distribution", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  border: Border.all(width: 10, color: Colors.pink.shade200)
                ),
                child: Center(
                  child: Text("$total\nLogs", textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                ),
              ),
              const SizedBox(width: 20),
              Expanded(child: _buildLegend(counts)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Map<String, int> counts) {
    final colors = {
      "Happy": Colors.amber, 
      "Amazing": Colors.pink, 
      "Calm": Colors.blue.shade200, 
      "Sad": Colors.purple, 
      "Angry": Colors.red,
      "Anxious": Colors.orange,
    };

    return Column(
      children: counts.entries.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(Icons.circle, size: 10, color: colors[e.key] ?? Colors.grey),
            const SizedBox(width: 8),
            Text("${e.key}: ${e.value}"),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSymptomsSection(List<MapEntry<String, int>> factors, int totalLogs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Most Common Factors/Symptoms", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (factors.isEmpty) const Text("No data yet", style: TextStyle(color: Colors.grey)),
          ...factors.take(5).map((f) {
            double percentage = totalLogs > 0 ? f.value / totalLogs : 0;
            return _buildSymptomBar(f.key, percentage);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSymptomBar(String label, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade100, color: Colors.pinkAccent)),
          const SizedBox(width: 10),
          Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFooter(int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: Colors.pink),
          const SizedBox(width: 10),
          Expanded(child: Text("Total of $total wellness check-ins recorded across the community.")),
        ],
      ),
    );
  }
}
