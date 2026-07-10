import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_analytics_viewmodel.dart';

class AdminNutritionTrackerScreen extends StatefulWidget {
  const AdminNutritionTrackerScreen({super.key});

  @override
  State<AdminNutritionTrackerScreen> createState() => _AdminNutritionTrackerScreenState();
}

class _AdminNutritionTrackerScreenState extends State<AdminNutritionTrackerScreen> {
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

    final tagEntries = vm.tagFrequency.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
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
        backgroundColor: const Color(0xFFF0FFFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4F8FE0)),
        title: const Text(
          "Nutrition Analytics",
          style: TextStyle(color: Color(0xFF4F8FE0), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (vm.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                ),
                child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500)),
              ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFEAF3FD), shape: BoxShape.circle),
                    child: const Icon(Icons.info_outline, color: Color(0xFF4F8FE0), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      tagEntries.isEmpty
                          ? "No nutrition tags logged yet."
                          : "'\$topTag' is the most logged tag, appearing in ${topTagPercent.toStringAsFixed(0)}% of tagged logs.",
                      style: const TextStyle(fontSize: 14, color: Color(0xFF2A2A2A), fontWeight: FontWeight.w500, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 2.2,
              children: [
                _statCard(Icons.restaurant_menu, const Color(0xFF9B7FE8), "Total Logs", "${vm.mealEntries}"),
                _statCard(Icons.people, const Color(0xFF6FC3F7), "Active Users", "${vm.distinctMealUsers}"),
                _statCard(Icons.today, const Color(0xFF7AC74F), "Logged Today", "${vm.todayMealEntries}"),
                _statCard(Icons.repeat, const Color(0xFFFFB74D), "Avg Logs/User", avgMealsPerUser.toStringAsFixed(1)),
                _statCard(Icons.home, const Color(0xFF7AC74F), "Home-cooked", "${homeCookedPercent.toStringAsFixed(0)}%"),
                _statCard(Icons.label, const Color(0xFFEF8FA8), "Top Tag", topTag),
                _statCard(Icons.local_fire_department, const Color(0xFFFF7D7D), "Consistency", "${vm.mealLoggingConsistency.toStringAsFixed(0)}%"),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nutrition Logs Trend (7 days)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A))),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                        ),
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
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                  radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: const Color(0xFF9B7FE8)
                              ),
                            ),
                            belowBarData: BarAreaData(show: true, color: const Color(0xFF9B7FE8).withOpacity(0.15)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Total logs across all users, per day", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Log Type Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A))),
                  const SizedBox(height: 20),
                  mealTotal == 0
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text("No nutrition logs yet", style: TextStyle(color: Colors.grey))),
                  )
                      : SizedBox(
                    height: 180,
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              sections: vm.mealTypeDistribution.entries.where((e) => e.value > 0).map((e) {
                                return PieChartSectionData(
                                  value: e.value.toDouble(),
                                  color: mealColors[e.key],
                                  title: "${e.value}",
                                  radius: 40,
                                  titleStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: vm.mealTypeDistribution.entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Container(width: 12, height: 12, decoration: BoxDecoration(color: mealColors[e.key], shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Text("${e.key}: ${e.value}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF5A5A5A))),
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

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Most Common Tags", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A))),
                  const SizedBox(height: 16),
                  tagEntries.isEmpty
                      ? const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("No tags logged yet", style: TextStyle(color: Colors.grey)))
                      : Column(
                    children: List.generate(tagEntries.length, (i) {
                      final e = tagEntries[i];
                      final maxVal = tagEntries.first.value;
                      final color = tagColors[i % tagColors.length];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2A2A2A))),
                                Text("${e.value}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: maxVal == 0 ? 0 : e.value / maxVal,
                                minHeight: 10,
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

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Recent Entries", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A))),
                  const SizedBox(height: 16),
                  vm.recentMealEntries.isEmpty
                      ? const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("No entries yet", style: TextStyle(color: Colors.grey)))
                      : Column(
                    children: vm.recentMealEntries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFF9B7FE8).withOpacity(0.15), shape: BoxShape.circle),
                              child: const Icon(Icons.restaurant_menu, size: 20, color: Color(0xFF9B7FE8)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("User ${vm.maskId(entry['userId'])}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A))),
                                  Text("${entry['mealCount']} logs", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF9B7FE8))),
                                ],
                              ),
                            ),
                            Text("${entry['date']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2A2A2A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
