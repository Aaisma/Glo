import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodSummaryScreen extends StatefulWidget {
  const MoodSummaryScreen({super.key});

  @override
  State<MoodSummaryScreen> createState() => _MoodSummaryScreenState();
}

class _MoodSummaryScreenState extends State<MoodSummaryScreen> {
  // You can update these values from your database/provider using setState()
  double amazing = 2;
  double happy = 5;
  double calm = 3;
  double neutral = 2;
  double sad = 1;
  double angry = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      appBar: AppBar(
        title: const Text("Mood Summary", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Donut Chart Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("This Week", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        height: 140, width: 140,
                        child: PieChart(PieChartData(
                          centerSpaceRadius: 45,
                          sections: [
                            PieChartSectionData(value: amazing, color: Colors.pink, radius: 25, showTitle: false),
                            PieChartSectionData(value: happy, color: Colors.amber, radius: 25, showTitle: false),
                            PieChartSectionData(value: calm, color: Colors.blue, radius: 25, showTitle: false),
                            PieChartSectionData(value: neutral, color: Colors.grey, radius: 25, showTitle: false),
                          ],
                        )),
                      ),
                      const SizedBox(width: 20),
                      // Legend List
                      Expanded(
                        child: Column(
                          children: [
                            _buildLegendItem("Amazing", amazing, Colors.pink),
                            _buildLegendItem("Happy", happy, Colors.amber),
                            _buildLegendItem("Calm", calm, Colors.blue),
                            _buildLegendItem("Neutral", neutral, Colors.grey),
                            _buildLegendItem("Sad", sad, Colors.purple),
                            _buildLegendItem("Angry", angry, Colors.red),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, double count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text("${count.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}