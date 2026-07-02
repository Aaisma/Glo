import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_analytics_viewmodel.dart';

class AdminHydrationHubScreen extends StatefulWidget {
  const AdminHydrationHubScreen({super.key});

  @override
  State<AdminHydrationHubScreen> createState() => _AdminHydrationHubScreenState();
}

class _AdminHydrationHubScreenState extends State<AdminHydrationHubScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminAnalyticsViewModel>().loadData());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminAnalyticsViewModel>();
    final maxTrend = vm.waterIntakeTrend.values.isEmpty
        ? 1.0
        : vm.waterIntakeTrend.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF3FD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4F8FE0)),
        title: const Text("Hydration Reports", style: TextStyle(color: Color(0xFF4F8FE0))),
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

            if (vm.dehydrationRiskRate > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Color(0xFFFF7D7D), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "${vm.dehydrationRiskRate.toStringAsFixed(0)}% of logged entries are below half the user's daily goal.",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF2A2A2A)),
                      ),
                    ),
                  ],
                ),
              ),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: [
                _statCard(Icons.water_drop, const Color(0xFF6FC3F7), "Avg Intake", "${vm.averageWaterIntake.toStringAsFixed(1)} L"),
                _statCard(Icons.flag, const Color(0xFF7AC74F), "Goal Reached", "${vm.waterGoalCompletion.toStringAsFixed(0)}%"),
                _statCard(Icons.assignment, const Color(0xFF9B7FE8), "Entries", "${vm.waterEntries}"),
                _statCard(Icons.people, const Color(0xFFFFB74D), "Active Users", "${vm.distinctWaterUsers}"),
                _statCard(Icons.today, const Color(0xFF4F8FE0), "Logged Today", "${vm.todayWaterEntries}"),
                _statCard(Icons.emoji_events, const Color(0xFFEF8FA8), "Met Goal Today", "${vm.usersMetGoalToday}"),
                _statCard(Icons.local_fire_department, const Color(0xFF6FC3F7), "Top Drinker",
                    vm.highestIntakeUser != null ? vm.maskId(vm.highestIntakeUser!["userId"]) : "—"),
                _statCard(Icons.warning_amber, const Color(0xFFFF7D7D), "Dehydration Risk", "${vm.dehydrationRiskRate.toStringAsFixed(0)}%"),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Hydration Trend (7 days)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: maxTrend == 0 ? 1 : maxTrend * 1.2,
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: vm.waterIntakeTrend.entries.toList().asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value.value);
                            }).toList(),
                            isCurved: true,
                            color: const Color(0xFF6FC3F7),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: const Color(0xFF6FC3F7).withOpacity(0.15)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("Average daily intake (L) across all users", style: TextStyle(fontSize: 10, color: Colors.grey)),
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
                  const Text("Lowest Intake Users", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  vm.lowestIntakeUsers.isEmpty
                      ? const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("No data yet", style: TextStyle(color: Colors.grey)))
                      : Column(
                    children: vm.lowestIntakeUsers.map((u) {
                      final intake = u["avgIntake"] as double;
                      final goal = u["avgGoal"] as double;
                      final progress = goal > 0 ? (intake / goal).clamp(0.0, 1.0) : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(backgroundColor: const Color(0xFF6FC3F7).withOpacity(0.15), child: const Icon(Icons.person, color: Color(0xFF6FC3F7), size: 16)),
                                const SizedBox(width: 10),
                                Expanded(child: Text("User ${vm.maskId(u["userId"])}", style: const TextStyle(fontSize: 13))),
                                Text("${intake.toStringAsFixed(1)} / ${goal.toStringAsFixed(1)} L", style: const TextStyle(fontSize: 11, color: Color(0xFFFF7D7D), fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFEAF3FD),
                                color: progress < 0.5 ? const Color(0xFFFF7D7D) : const Color(0xFF6FC3F7),
                              ),
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
                  const Text("Recent Logs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  vm.recentWaterEntries.isEmpty
                      ? const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("No entries yet", style: TextStyle(color: Colors.grey)))
                      : Column(
                    children: vm.recentWaterEntries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.water_drop, size: 16, color: Color(0xFF6FC3F7)),
                            const SizedBox(width: 8),
                            Expanded(child: Text("User ${vm.maskId(entry["userId"])} — ${entry["intake"]} L", style: const TextStyle(fontSize: 12))),
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
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A)), textAlign: TextAlign.center),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}