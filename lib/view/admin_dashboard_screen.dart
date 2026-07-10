import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'admin_skin_journal_screen.dart';
import 'admin_hydration_hub_screen.dart';
import 'admin_nutrition_tracker_screen.dart';
import './dashboard_card/admin/admin_monthly_tracking_screen.dart';

enum ChartView { bar, line, pie }

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  ChartView _chartView = ChartView.bar;

  final List<String> _featureLabels = ["Daily Tips", "Skincare Quiz", "Routine Tracker", "Water Intake"];
  final List<double> _featureValues = [12, 8, 5, 4];
  final List<Color> _featureColors = [
    const Color(0xFF4F8FE0),
    const Color(0xFF9B7FE8),
    const Color(0xFFFFB74D),
    const Color(0xFF6FC3F7),
  ];

  final List<Map<String, dynamic>> _topUsers = [
    {"name": "Alex Mercer", "hours": "2.1h/day", "color": const Color(0xFF4F8FE0)},
    {"name": "Sam Carter", "hours": "1.8h/day", "color": const Color(0xFF9B7FE8)},
    {"name": "Jordan Lee", "hours": "1.5h/day", "color": const Color(0xFFFFB74D)},
    {"name": "Casey Smith", "hours": "1.1h/day", "color": const Color(0xFF6FC3F7)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFF),
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FFFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4F8FE0)),
        title: const Text(
          "✨ Glow begins with care ✨",
          style: TextStyle(
            color: Color(0xFF4F8FE0),
            fontStyle: FontStyle.italic,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              avatar: const CircleAvatar(
                backgroundColor: Color(0xFFEAF3FD),
                child: Icon(Icons.admin_panel_settings, size: 16, color: Color(0xFF4F8FE0)),
              ),
              label: const Text(
                "Admin",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F8FE0)),
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: const Color(0xFF4F8FE0).withOpacity(0.2)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.0,
              children: [
                _statCard(Icons.person, const Color(0xFF4F8FE0), "Total Users", "4"),
                _statCard(Icons.person_outline, const Color(0xFF7AC74F), "Active Users", "3"),
                _statCard(Icons.chat_bubble, const Color(0xFF9B7FE8), "Posts Today", "6"),
                _statCard(Icons.person_add, const Color(0xFFFFB74D), "New Signups", "1"),
              ],
            ),

            const SizedBox(height: 24),

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Top Used Features",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _viewToggleButton("Bar", ChartView.bar),
                            _viewToggleButton("Line", ChartView.line),
                            _viewToggleButton("Pie", ChartView.pie),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(height: 200, child: _buildChart()),
                ],
              ),
            ),

            const SizedBox(height: 24),

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
                  const Text(
                    "Top Active Users",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A)),
                  ),
                  const SizedBox(height: 16),
                  ..._topUsers.map((user) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: (user["color"] as Color).withOpacity(0.15),
                            child: Icon(Icons.person, color: user["color"], size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              user["name"],
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF2A2A2A)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (user["color"] as Color).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user["hours"],
                              style: TextStyle(color: user["color"], fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _viewToggleButton(String label, ChartView view) {
    final selected = _chartView == view;
    return GestureDetector(
      onTap: () => setState(() => _chartView = view),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? const Color(0xFF4F8FE0) : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (_chartView) {
      case ChartView.bar:
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 15,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= _featureLabels.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _featureLabels[i],
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF5A5A5A)),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(_featureValues.length, (i) {
              return BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: _featureValues[i],
                  color: _featureColors[i],
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 15,
                    color: _featureColors[i].withOpacity(0.1),
                  ),
                ),
              ]);
            }),
          ),
        );
      case ChartView.line:
        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            minY: 0,
            maxY: 15,
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= _featureLabels.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _featureLabels[i],
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF5A5A5A)),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(_featureValues.length, (i) => FlSpot(i.toDouble(), _featureValues[i])),
                isCurved: true,
                color: const Color(0xFF4F8FE0),
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: const Color(0xFF4F8FE0),
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF4F8FE0).withOpacity(0.1),
                ),
              ),
            ],
          ),
        );
      case ChartView.pie:
        return PieChart(
          PieChartData(
            sectionsSpace: 4,
            centerSpaceRadius: 40,
            sections: List.generate(_featureValues.length, (i) {
              return PieChartSectionData(
                value: _featureValues[i],
                color: _featureColors[i],
                title: '${_featureValues[i].toInt()}',
                radius: 50,
                titleStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                badgeWidget: _Badge(
                  _featureLabels[i].split(' ').first,
                  size: 30,
                  borderColor: _featureColors[i],
                ),
                badgePositionPercentageOffset: 1.1,
              );
            }),
          ),
        );
    }
  }

  Widget _statCard(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2A2A2A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final items = [
      {"icon": Icons.dashboard, "label": "Dashboard"},
      {"icon": Icons.person, "label": "Users"},
      {"icon": Icons.forum, "label": "Community Feed"},
      {"icon": Icons.bar_chart, "label": "Insights"},
      {"icon": Icons.favorite, "label": "Health Overview"},
      {"icon": Icons.spa, "label": "Wellness Journey"},
      {"icon": Icons.calendar_month, "label": "Monthly Tracking"},
      {"icon": Icons.book, "label": "Skin Journal"},
      {"icon": Icons.water_drop, "label": "Hydration Hub"},
      {"icon": Icons.restaurant_menu, "label": "Nutrition Tracker"},
      {"icon": Icons.feedback, "label": "Feedback"},
      {"icon": Icons.logout, "label": "Logout"},
    ];

    return Drawer(
      backgroundColor: const Color(0xFFF0FFFF),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFEAF3FD), width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.dashboard_customize, color: Color(0xFF4F8FE0)),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Admin Panel",
                    style: TextStyle(color: Color(0xFF2A2A2A), fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 10),
                children: items.asMap().entries.map((entry) {
                  final isActive = entry.key == 0;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pop(context);
                          if (item["label"] == "Skin Journal") {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSkinJournalScreen()));
                          } else if (item["label"] == "Hydration Hub") {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminHydrationHubScreen()));
                          } else if (item["label"] == "Nutrition Tracker") {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNutritionTrackerScreen()));
                          } else if (item["label"] == "Monthly Tracking") {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMonthlyTrackingScreen()));
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFF4F8FE0) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item["icon"] as IconData,
                                color: isActive ? Colors.white : const Color(0xFF5A5A5A),
                                size: 22,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                item["label"] as String,
                                style: TextStyle(
                                  color: isActive ? Colors.white : const Color(0xFF2A2A2A),
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final double size;
  final Color borderColor;

  const _Badge(this.text, {required this.size, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size * 1.5,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A)),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}