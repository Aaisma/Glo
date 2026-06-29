import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_analytics_viewmodel.dart';

class AdminSkinJournalScreen extends StatefulWidget {
  const AdminSkinJournalScreen({super.key});

  @override
  State<AdminSkinJournalScreen> createState() => _AdminSkinJournalScreenState();
}

class _AdminSkinJournalScreenState extends State<AdminSkinJournalScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminAnalyticsViewModel>().loadData());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminAnalyticsViewModel>();
    final colors = {
      "Clear": const Color(0xFF6FC3F7),
      "Mild": const Color(0xFFFFB74D),
      "Moderate": const Color(0xFFEF8FA8),
      "Severe": const Color(0xFF9B7FE8),
    };
    final total = vm.severityDistribution.values.fold(0, (a, b) => a + b);
    final changeText = vm.severeChangePercent >= 0
        ? "Severe cases up ${vm.severeChangePercent.toStringAsFixed(0)}% this week. Monitor closely."
        : "Severe cases down ${vm.severeChangePercent.abs().toStringAsFixed(0)}% this week. Good progress.";

    String mostCommon = "—";
    if (total > 0) {
      final sorted = vm.severityDistribution.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      mostCommon = sorted.first.key;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2D5E78),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF3FD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4F8FE0)),
        title: const Text("Skin Analytics", style: TextStyle(color: Color(0xFF4F8FE0))),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Color(0xFF4F8FE0), size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(changeText, style: const TextStyle(fontSize: 12, color: Color(0xFF2A2A2A)))),
                ],
              ),
            ),

            const SizedBox(height: 14),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: [
                _statCard(Icons.face_retouching_natural, const Color(0xFF9B7FE8), "Total Entries", "${vm.acneEntries}"),
                _statCard(Icons.people, const Color(0xFF6FC3F7), "Active Users", "${vm.distinctAcneUsers}"),
                _statCard(Icons.today, const Color(0xFF7AC74F), "Logged Today", "${vm.todayAcneEntries}"),
                _statCard(Icons.warning_amber, const Color(0xFFFF7D7D), "Severe Cases", "${vm.severityDistribution["Severe"]}"),
                _statCard(Icons.trending_up, const Color(0xFFFFB74D), "Most Common", mostCommon),
                _statCard(Icons.checklist, const Color(0xFFEF8FA8), "Avg Routine", "${vm.averageChecklistCompletion.toStringAsFixed(0)}%"),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Severity Breakdown", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  total == 0
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text("No acne entries logged yet", style: TextStyle(color: Colors.grey))),
                  )
                      : SizedBox(
                    height: 160,
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 35,
                              sections: vm.severityDistribution.entries.where((e) => e.value > 0).map((e) {
                                return PieChartSectionData(
                                  value: e.value.toDouble(),
                                  color: colors[e.key],
                                  title: "${e.value}",
                                  radius: 40,
                                  titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: vm.severityDistribution.entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[e.key], shape: BoxShape.circle)),
                                  const SizedBox(width: 6),
                                  Text("${e.key}: ${e.value}", style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Severity Trend (7 days)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: 3,
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: vm.severityTrend.entries.toList().asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value.value);
                            }).toList(),
                            isCurved: true,
                            color: const Color(0xFF4F8FE0),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: const Color(0xFF4F8FE0).withOpacity(0.15)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("0 = Clear, 1 = Mild, 2 = Moderate, 3 = Severe", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Most Logged Products", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  vm.topProducts.isEmpty
                      ? const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("No products logged yet", style: TextStyle(color: Colors.grey)))
                      : Column(
                    children: vm.topProducts.map((p) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(p["name"], style: const TextStyle(fontSize: 13))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFEAF3FD), borderRadius: BorderRadius.circular(8)),
                              child: Text("${p["count"]}", style: const TextStyle(fontSize: 11, color: Color(0xFF4F8FE0))),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Recent Entries", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  vm.recentAcneEntries.isEmpty
                      ? const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("No entries yet", style: TextStyle(color: Colors.grey)))
                      : Column(
                    children: vm.recentAcneEntries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.face_retouching_natural, size: 16, color: colors[entry["severity"]] ?? Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(child: Text("User ${vm.maskId(entry["userId"])} — ${entry["severity"]}", style: const TextStyle(fontSize: 12))),
                            Text("${entry["date"]}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A))),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}