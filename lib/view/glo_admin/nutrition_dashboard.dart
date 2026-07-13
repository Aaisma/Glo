import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/admin_analytics_viewmodel.dart';

class NutritionDashboard extends StatefulWidget {
  const NutritionDashboard({super.key});

  @override
  State<NutritionDashboard> createState() => _NutritionDashboardState();
}

class _NutritionDashboardState extends State<NutritionDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminAnalyticsViewModel>().loadData());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminAnalyticsViewModel>();

    final tagColors = [
      const Color(0xFFFFB74D),
      const Color(0xFF6FC3F7),
      const Color(0xFF9B7FE8),
      const Color(0xFFEF8FA8),
      const Color(0xFF7AC74F),
    ];

    final mealColors = {
      "Breakfast": const Color(0xFFFFB74D),
      "Lunch": const Color(0xFF6FC3F7),
      "Dinner": const Color(0xFF9B7FE8),
      "Snack": const Color(0xFFEF8FA8),
    };

    final tagEntries = vm.tagFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mealTotal = vm.mealTypeDistribution.values.fold(0, (a, b) => a + b);

    final avgMealsPerUser = vm.distinctMealUsers == 0 ? 0.0 : vm.mealEntries / vm.distinctMealUsers;

    final homeCookedCount = vm.tagFrequency["Home-cooked"] ?? 0;
    final totalTagsLogged = vm.tagFrequency.values.fold(0, (a, b) => a + b);
    final homeCookedPercent = totalTagsLogged == 0 ? 0.0 : (homeCookedCount / totalTagsLogged) * 100;

    String topTag = tagEntries.isEmpty ? "—" : tagEntries.first.key;
    final topTagPercent = totalTagsLogged == 0 || tagEntries.isEmpty ? 0.0 : (tagEntries.first.value / totalTagsLogged) * 100;

    final maxMealsTrend = vm.mealsLoggedTrend.values.isEmpty
        ? 1.0
        : vm.mealsLoggedTrend.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF3FD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4F8FE0)),
        title: const Text("Nutrition Dashboard", style: TextStyle(color: Color(0xFF4F8FE0))),
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
                  Expanded(
                    child: Text(
                      tagEntries.isEmpty
                          ? "No meal tags logged yet."
                          : "'$topTag' is the most logged tag, appearing in ${topTagPercent.toStringAsFixed(0)}% of tagged meals.",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF2A2A2A)),
                    ),
                  ),
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
                _statCard(Icons.restaurant_menu, const Color(0xFF9B7FE8), "Total Entries", "${vm.mealEntries}"),
                _statCard(Icons.people, const Color(0xFF6FC3F7), "Active Users", "${vm.distinctMealUsers}"),
                _statCard(Icons.today, const Color(0xFF7AC74F), "Logged Today", "${vm.todayMealEntries}"),
                _statCard(Icons.repeat, const Color(0xFFFFB74D), "Avg Meals/User", avgMealsPerUser.toStringAsFixed(1)),
                _statCard(Icons.home, const Color(0xFF7AC74F), "Home-cooked", "${homeCookedPercent.toStringAsFixed(0)}%"),
                _statCard(Icons.label, const Color(0xFFEF8FA8), "Top Tag", topTag),
                _statCard(Icons.local_fire_department, const Color(0xFFFF7D7D), "7-Day Consistency", "${vm.mealLoggingConsistency.toStringAsFixed(0)}%"),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Meals Logged Trend (7 days)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: maxMealsTrend == 0 ? 1 : maxMealsTrend * 1.2,
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: vm.mealsLoggedTrend.entries.toList().asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value.value);
                            }).toList(),
                            isCurved: true,
                            color: const Color(0xFF9B7FE8),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: const Color(0xFF9B7FE8).withValues(alpha: 0.15)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("Total meals logged across all users, per day", style: TextStyle(fontSize: 10, color: Colors.grey)),
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
                  const Text("Meal Type Distribution", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  mealTotal == 0
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text("No meals logged yet", style: TextStyle(color: Colors.grey))),
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
                              sections: vm.mealTypeDistribution.entries.where((e) => e.value > 0).map((e) {
                                return PieChartSectionData(
                                  value: e.value.toDouble(),
                                  color: mealColors[e.key],
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
                          children: vm.mealTypeDistribution.entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Container(width: 8, height: 8, decoration: BoxDecoration(color: mealColors[e.key], shape: BoxShape.circle)),
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
                  const Text("Most Common Tags", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  tagEntries.isEmpty
                      ? const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("No tags logged yet", style: TextStyle(color: Colors.grey)))
                      : Column(
                    children: List.generate(tagEntries.length, (i) {
                      final e = tagEntries[i];
                      final maxVal = tagEntries.first.value;
                      final color = tagColors[i % tagColors.length];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key, style: const TextStyle(fontSize: 12)),
                                Text("${e.value}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: maxVal == 0 ? 0 : e.value / maxVal,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFEAF3FD),
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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
                  vm.recentMealEntries.isEmpty
                      ? const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("No entries yet", style: TextStyle(color: Colors.grey)))
                      : Column(
                    children: vm.recentMealEntries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.restaurant_menu, size: 16, color: Color(0xFF9B7FE8)),
                            const SizedBox(width: 8),
                            Expanded(child: Text("${vm.displayNameForUser(entry["userId"] as String?)} — ${entry["mealCount"]} meals", style: const TextStyle(fontSize: 12))),
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