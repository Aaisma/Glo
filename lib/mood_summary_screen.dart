import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodSummaryScreen extends StatefulWidget {
  const MoodSummaryScreen({super.key});

  @override
  State<MoodSummaryScreen> createState() => _MoodSummaryScreenState();
}

class _MoodSummaryScreenState extends State<MoodSummaryScreen> {
  final Map<String, double> moodPercentages = {
    "Amazing": 14,
    "Happy": 36,
    "Calm": 21,
    "Neutral": 14,
    "Sad": 7,
    "Angry": 7,
  };

  final List<FlSpot> moodJourney = const [
    FlSpot(0, 4),
    FlSpot(1, 5),
    FlSpot(2, 3),
    FlSpot(3, 2),
    FlSpot(4, 4),
    FlSpot(5, 1),
    FlSpot(6, 2),
  ];

  final Map<String, String> weeklyStats = {
    "Total Logs": "14",
    "Positive Days": "8",
    "Calm Days": "3",
    "Self-care Days": "2",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text("Mood Summary"),
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("This Week",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Pie Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: moodPercentages.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value,
                      color: _colorForMood(entry.key),
                      radius: 60,
                      title: "${entry.key}\n${entry.value.toInt()}%",
                      titleStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You felt happy most of the time this week! Keep doing what makes you feel good.",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 24),
            const Text("Your Mood Journey",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Line Chart
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            "Mon",
                            "Tue",
                            "Wed",
                            "Thu",
                            "Fri",
                            "Sat",
                            "Sun"
                          ];
                          return Text(days[value.toInt() % days.length]);
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.pinkAccent,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      spots: moodJourney,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text("This Week in a Nutshell",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: weeklyStats.entries
                  .map((e) => _StatCard(title: e.key, value: e.value))
                  .toList(),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: const Text(
                "“You’re allowed to be both a masterpiece and a work in progress.”",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForMood(String mood) {
    switch (mood) {
      case "Amazing":
        return Colors.green;
      case "Happy":
        return Colors.yellow;
      case "Calm":
        return Colors.blue;
      case "Neutral":
        return Colors.grey;
      case "Sad":
        return Colors.purple;
      case "Angry":
        return Colors.red;
      default:
        return Colors.black26;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Text(value,
              style:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
