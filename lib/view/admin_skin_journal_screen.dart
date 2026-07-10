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
      final sorted = vm.severityDistribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      mostCommon = sorted.first.key;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FFFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4F8FE0)),
        title: const Text(
          "Skin Analytics",
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
                    color: Colors.redAccent.withOpacity(0.5),
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

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                      color: const Color(0xFFEAF3FD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.insights,
                      color: Color(0xFF4F8FE0),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      changeText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2A2A2A),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
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
                _statCard(
                  Icons.face_retouching_natural,
                  const Color(0xFF9B7FE8),
                  "Total Entries",
                  "${vm.acneEntries}",
                ),
                _statCard(
                  Icons.people,
                  const Color(0xFF6FC3F7),
                  "Active Users",
                  "${vm.distinctAcneUsers}",
                ),
                _statCard(
                  Icons.today,
                  const Color(0xFF7AC74F),
                  "Logged Today",
                  "${vm.todayAcneEntries}",
                ),
                _statCard(
                  Icons.warning_amber,
                  const Color(0xFFFF7D7D),
                  "Severe Cases",
                  "${vm.severityDistribution['Severe'] ?? 0}",
                ),
                _statCard(
                  Icons.trending_up,
                  const Color(0xFFFFB74D),
                  "Most Common",
                  mostCommon,
                ),
                _statCard(
                  Icons.checklist,
                  const Color(0xFFEF8FA8),
                  "Avg Routine",
                  "${vm.averageChecklistCompletion.toStringAsFixed(0)}%",
                ),
                _statCard(
                  Icons.camera_alt,
                  const Color(0xFF6FC3F7),
                  "Photo Attach",
                  "${vm.photoAttachmentRate.toStringAsFixed(0)}%",
                ),
                _statCard(
                  Icons.shopping_bag,
                  const Color(0xFFFFB74D),
                  "Avg Products",
                  vm.averageProductsPerEntry.toStringAsFixed(1),
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
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Severity Breakdown",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  total == 0
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "No acne entries logged yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
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
                              sections: vm
                                  .severityDistribution
                                  .entries
                                  .where((e) => e.value > 0)
                                  .map((e) {
                                return PieChartSectionData(
                                  value: e.value.toDouble(),
                                  color: colors[e.key],
                                  title: "${e.value}",
                                  radius: 40,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              })
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: vm.severityDistribution.entries
                              .map((e) {
                            return Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: colors[e.key],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${e.key}: ${e.value}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                      FontWeight.w500,
                                      color: Color(0xFF5A5A5A),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                              .toList(),
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
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Severity Trend (7 days)",
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
                            color: Colors.grey.withOpacity(0.1),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: 3,
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
                            spots: vm.severityTrend.entries
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
                            color: const Color(0xFF9B7FE8),
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
                                      0xFF9B7FE8,
                                    ),
                                  ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(
                                0xFF9B7FE8,
                              ).withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "0 = Clear, 1 = Mild, 2 = Moderate, 3 = Severe",
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
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Most Logged Products",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  vm.topProducts.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "No products logged yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : Column(
                    children: vm.topProducts.map((p) {
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
                              Expanded(
                                child: Text(
                                  p["name"],
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
                                  color: const Color(0xFFEAF3FD),
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${p['count']}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4F8FE0),
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
                    color: Colors.black.withOpacity(0.04),
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
                  vm.recentAcneEntries.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "No entries yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : Column(
                    children: vm.recentAcneEntries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                (colors[entry["severity"]] ??
                                    Colors.grey)
                                    .withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.face_retouching_natural,
                                size: 20,
                                color:
                                colors[entry["severity"]] ??
                                    Colors.grey,
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
                                    entry["severity"],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color:
                                      colors[entry["severity"]] ??
                                          Colors.grey,
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
            color: color.withOpacity(0.1),
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
              color: color.withOpacity(0.12),
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
