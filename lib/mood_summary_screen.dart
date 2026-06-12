import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text("Mood Summary", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDonutChartCard(),
            const SizedBox(height: 16),
            _buildLineChartCard(),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 16),
            _buildQuoteCard(),
          ],
        ),
      ),
    );
  }

  // --- Widget Components ---

  Widget _buildDonutChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Align(alignment: Alignment.topLeft, child: Text("Your Mood Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: 36, color: Colors.amber, title: ''),
                  PieChartSectionData(value: 21, color: Colors.blue, title: ''),
                  // Add remaining sections...
                ],
                centerSpaceRadius: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartCard() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) => Text(['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][val.toInt()]))),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: const [FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 3), FlSpot(3, 2), FlSpot(4, 4), FlSpot(5, 5), FlSpot(6, 2)],
              isCurved: true,
              gradient: const LinearGradient(colors: [Colors.purple, Colors.blue]),
              barWidth: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statItem("14", "Total Logs", Colors.pink),
        _statItem("8", "Positive Days", Colors.amber),
        // Add other two...
      ],
    );
  }

  Widget _statItem(String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(children: [Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), Text(label)]),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(20)),
      child: const Text("“You're allowed to be both a masterpiece and a work in progress.”", textAlign: TextAlign.center, style: TextStyle(fontStyle: FontStyle.italic)),
    );
  }
}