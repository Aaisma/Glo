import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/admin_analytics_viewmodel.dart';

class AdminHydrationHubScreen extends StatefulWidget {
  const AdminHydrationHubScreen({super.key});

  @override
  State<AdminHydrationHubScreen> createState() =>
      _AdminHydrationHubScreenState();
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
        backgroundColor: const Color(0xFFF0FFFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4F8FE0)),
        title: const Text(
          "Hydration Reports",
          style: TextStyle(
            color: Color(0xFF4F8FE0),
            fontWeight: FontWeight.bold,
          ),
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
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            if (vm.dehydrationRiskRate > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF7D7D).withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF7D7D).withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7D7D).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFF7D7D),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "${vm.dehydrationRiskRate.toStringAsFixed(0)}% of logged entries are below half the user's daily goal. Keep an eye on hydration reminders.",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFC62828),
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 2.2,
              children: [
                _statCard(
                  Icons.water_drop,
                  const Color(0xFF6FC3F7),
                  "Avg Intake",
                  "${vm.averageWaterIntake.toStringAsFixed(1)} L",
                ),
                _statCard(
                  Icons.flag,
                  const Color(0xFF7AC74F),
                  "Goal Reached",
                  "${vm.waterGoalCompletion.toStringAsFixed(0)}%",
                ),
                _statCard(
                  Icons.assignment,
                  const Color(0xFF9B7FE8),
                  "Total Entries",
                  "${vm.waterEntries}",
                ),
                _statCard(
                  Icons.people,
                  const Color(0xFFFFB74D),
                  "Active Users",
                  "${vm.distinctWaterUsers}",
                ),
                _statCard(
                  Icons.today,
                  const Color(0xFF4F8FE0),
                  "Logged Today",
                  "${vm.todayWaterEntries}",
                ),
                _statCard(
                  Icons.emoji_events,
                  const Color(0xFFEF8FA8),
                  "Goal Met Today",
                  "${vm.usersMetGoalToday}",
                ),
                _statCard(
                  Icons.local_fire_department,
                  const Color(0xFF6FC3F7),
                  "Top Drinker",
                  vm.highestIntakeUser != null
                      ? vm.displayNameForUser(
                    vm.highestIntakeUser!["userId"]?.toString(),
                  )
                      : "—",
                ),
                _statCard(
                  Icons.warning_amber,
                  const Color(0xFFFF7D7D),
                  "Dehydration Risk",
                  "${vm.dehydrationRiskRate.toStringAsFixed(0)}%",
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hydration Trend (7 days)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withValues(alpha: 0.1),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: maxTrend == 0 ? 1 : maxTrend * 1.2,
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: vm.waterIntakeTrend.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((e) {
                              return FlSpot(
                                e.key.toDouble(),
                                e.value.value,
                              );
                            })
                                .toList(),
                            isCurved: true,
                            color: const Color(0xFF6FC3F7),
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter:
                                  (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: const Color(
                                      0xFF6FC3F7,
                                    ),
                                  ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(
                                0xFF6FC3F7,
                              ).withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Average daily intake (L) across all users",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
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
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Lowest Intake Users",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  vm.lowestIntakeUsers.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "No data yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : Column(
                    children: vm.lowestIntakeUsers.map((u) {
                      final val = (u['intake'] as num?)?.toDouble() ?? (u['avgIntake'] as num?)?.toDouble() ?? 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEAF3FD),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Color(0xFF4F8FE0),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  vm.displayNameForUser(
                                    u['userId']?.toString(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2A2A2A),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0F0),
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${val.toStringAsFixed(1)} L",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF7D7D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Highest Intake Users",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  vm.highestIntakeUsers.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "No data yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : Column(
                    children: vm.highestIntakeUsers.map((u) {
                      final val = (u['intake'] as num?)?.toDouble() ?? (u['avgIntake'] as num?)?.toDouble() ?? 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEAFDF3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  vm.displayNameForUser(
                                    u['userId']?.toString(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2A2A2A),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAFDF3),
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${val.toStringAsFixed(1)} L",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Entries",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  vm.recentWaterEntries.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "No entries yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : Column(
                    children: vm.recentWaterEntries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6FC3F7,
                                ).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.water_drop,
                                size: 20,
                                color: Color(0xFF6FC3F7),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vm.displayNameForUser(
                                      entry['userId']?.toString(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2A2A2A),
                                    ),
                                  ),
                                  Text(
                                    "${entry['intake']} ml",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6FC3F7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${entry['date']}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
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
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2A2A2A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}