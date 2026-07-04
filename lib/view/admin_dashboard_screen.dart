import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'admin_skin_journal_screen.dart';
import 'admin_hydration_hub_screen.dart';
import 'admin_meal_tracker_screen.dart';
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
  final List<double> _featureValues = [80, 65, 50, 40];
  final List<Color> _featureColors = [
    const Color(0xFF4F8FE0),
    const Color(0xFF9B7FE8),
    const Color(0xFFFFB74D),
    const Color(0xFF6FC3F7),
  ];

  final List<Map<String, dynamic>> _topUsers = [
    {"name": "Anjali Sharma", "hours": "5h/day", "color": Color(0xFF4F8FE0)},
    {"name": "Priya Singh", "hours": "4.2h/day", "color": Color(0xFF9B7FE8)},
    {"name": "Rahul Verma", "hours": "3.8h/day", "color": Color(0xFFFFB74D)},
    {"name": "Neha Patel", "hours": "3h/day", "color": Color(0xFF6FC3F7)},
    {"name": "Sagar Gupta", "hours": "2.5h/day", "color": Color(0xFF7AC74F)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFFF),
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF3FD),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4F8FE0)),
        title: const Text(
          "✨ Glow begins with care ✨",
          style: TextStyle(color: Color(0xFF4F8FE0), fontStyle: FontStyle.italic, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 16, color: Color(0xFF4F8FE0))),
              label: const Text("Admin"),
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _statCard(Icons.person, const Color(0xFF4F8FE0), "Total Users", "8,450"),
                _statCard(Icons.person_outline, const Color(0xFF7AC74F), "Active Users", "2,320"),
                _statCard(Icons.chat_bubble, const Color(0xFF9B7FE8), "Posts Today", "135"),
                _statCard(Icons.person_add, const Color(0xFFFFB74D), "New Signups", "47"),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Top Used Features", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A))),
                      Row(
                        children: [
                          _viewToggleButton("Bar", ChartView.bar),
                          _viewToggleButton("Line", ChartView.line),
                          _viewToggleButton("Pie", ChartView.pie),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(height: 180, child: _buildChart()),
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
                  const Text("Top Active Users", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A))),
                  const SizedBox(height: 12),
                  ..._topUsers.map((user) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: (user["color"] as Color).withOpacity(0.2), child: Icon(Icons.person, color: user["color"])),
                        const SizedBox(width: 12),
                        Expanded(child: Text(user["name"], style: const TextStyle(fontWeight: FontWeight.w500))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (user["color"] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(user["hours"], style: TextStyle(color: user["color"], fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewToggleButton(String label, ChartView view) {
    final selected = _chartView == view;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: GestureDetector(
        onTap: () => setState(() => _chartView = view),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF4F8FE0) : const Color(0xFFEAF3FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label, style: TextStyle(fontSize: 11, color: selected ? Colors.white : const Color(0xFF4F8FE0))),
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
            maxY: 100,
            barTouchData: BarTouchData(enabled: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= _featureLabels.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(_featureLabels[i], style: const TextStyle(fontSize: 8)),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(_featureValues.length, (i) {
              return BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: _featureValues[i], color: _featureColors[i], width: 18, borderRadius: BorderRadius.circular(4)),
              ]);
            }),
          ),
        );
      case ChartView.line:
        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            minY: 0,
            maxY: 100,
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= _featureLabels.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(_featureLabels[i], style: const TextStyle(fontSize: 8)),
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
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: true, color: const Color(0xFF4F8FE0).withOpacity(0.15)),
              ),
            ],
          ),
        );
      case ChartView.pie:
        return PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 30,
            sections: List.generate(_featureValues.length, (i) {
              return PieChartSectionData(
                value: _featureValues[i],
                color: _featureColors[i],
                title: _featureValues[i].toInt().toString(),
                radius: 50,
                titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
              );
            }),
          ),
        );
    }
  }

  Widget _statCard(IconData icon, Color color, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2A2A2A))),
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
      {"icon": Icons.restaurant_menu, "label": "Meal Tracker"},
      {"icon": Icons.feedback, "label": "Feedback"},
      {"icon": Icons.logout, "label": "Logout"},
    ];

    return Drawer(
      backgroundColor: const Color(0xFFF0FFFF),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Icon(Icons.settings, color: Color(0xFF4F8FE0)),
                  SizedBox(width: 10),
                  Text("Admin Panel", style: TextStyle(color: Color(0xFF4F8FE0), fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: items.asMap().entries.map((entry) {
                  final isActive = entry.key == 0;
                  final item = entry.value;
                  return Container(
                    color: isActive ? const Color(0xFF4F8FE0).withOpacity(0.15) : Colors.transparent,
                    child: ListTile(
                      leading: Icon(item["icon"] as IconData, color: const Color(0xFF4F8FE0)),
                      title: Text(item["label"] as String, style: const TextStyle(color: Color(0xFF2A2A2A))),
                      onTap: () {
                        Navigator.pop(context);
                        if (item["label"] == "Skin Journal") {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSkinJournalScreen()));
                        } else if (item["label"] == "Hydration Hub") {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminHydrationHubScreen()));
                        } else if (item["label"] == "Meal Tracker") {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMealTrackerScreen()));
                        } else if (item["label"] == "Monthly Tracking") {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMonthlyTrackingScreen()));
                        }
                        // Feedback: your friend will wire her own screen into this case later
                      },
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