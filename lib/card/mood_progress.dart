import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodProgress extends StatelessWidget {
  final List<String> moods; // pass in your weekly moods

  const MoodProgress({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your mood this week",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(_buildChart()),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChart() {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int dayIndex = value.toInt();
              if (dayIndex >= 0 && dayIndex < moods.length) {
                return Text(
                  ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][dayIndex],
                  style: const TextStyle(fontSize: 12),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: const Color(0xFFFF3E63),
          barWidth: 3,
          dotData: FlDotData(show: true),
          spots: List.generate(
            moods.length,
                (index) => FlSpot(index.toDouble(), (index % 5 + 1).toDouble()),
          ),
        ),
      ],
    );
  }
}
