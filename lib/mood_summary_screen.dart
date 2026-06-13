import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodSummaryScreen extends StatefulWidget {
  const MoodSummaryScreen({Key? key}) : super(key: key);

  @override
  State<MoodSummaryScreen> createState() => _MoodSummaryScreenState();
}

class _MoodSummaryScreenState extends State<MoodSummaryScreen> {
  final Map<String, int> moodCounts = {
    "Calm": 3,
    "Neutral": 2,
    "Sad": 1,
    "Angry": 1,
    "Amazing": 2,
    "Happy": 5,
  };

  final int totalLogs = 14;
  final int happyDays = 8;
  final int calmDays = 3;
  final int selfCareDays = 2;

  final List<FlSpot> moodJourney = [
    FlSpot(0, 4),
    FlSpot(1, 5),
    FlSpot(2, 3),
    FlSpot(3, 2),
    FlSpot(4, 5),
    FlSpot(5, 1),
    FlSpot(6, 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mood Summary")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Pie Chart Section
            Column(
              children: [
                Text("Your Mood Summary",
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: moodCounts.entries.map((entry) {
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: entry.key,
                          radius: 50,
                          color: _getMoodColor(entry.key),
                          titleStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You felt happy most of the time this week! Keep doing what makes you feel good.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),

            // Line Chart Section
            Column(
              children: [
                Text("Your Mood Journey",
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: moodJourney,
                          isCurved: true,
                          color: Colors.pink,
                          barWidth: 4,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = [
                                "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
                              ];
                              return Text(days[value.toInt()]);
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Weekly Stats Section
            Column(
              children: [
                Text("This Week in a Nutshell",
                    style: Theme.of(context).textTheme.titleLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard("Total Logs", totalLogs.toString()),
                    _buildStatCard("Happy Days", happyDays.toString()),
                    _buildStatCard("Calm Days", calmDays.toString()),
                    _buildStatCard("Self-care", selfCareDays.toString()),
                  ],
                ),
              ],
            ),

            // Motivational Quote
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "You're allowed to be tired, a masterpiece and a work in progress.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(value,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case "Amazing":
        return Colors.green;
      case "Happy":
        return Colors.pink;
      case "Calm":
        return Colors.blue;
      case "Neutral":
        return Colors.grey;
      case "Sad":
        return Colors.indigo;
      case "Angry":
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
