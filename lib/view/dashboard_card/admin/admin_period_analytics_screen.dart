import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/admin_monthly_tracking_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glo/view/dashboard_card/admin/components/admin_tracking_components.dart';

class AdminPeriodAnalyticsScreen extends StatelessWidget {
  const AdminPeriodAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminMonthlyTrackingViewModel>();
    final data = vm.periodAnalytics;
    final isLoading = vm.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const AdminTrackingAppBar(title: "Period Analytics"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      TrackingStatCard(
                        title: "Avg Cycle Length",
                        value: "${data['avgCycleLength'] ?? 0}",
                        subtitle: "Days",
                        valueColor: const Color(0xFF4CAF50),
                      ),
                      TrackingStatCard(
                        title: "Avg Period Length",
                        value: "${data['avgPeriodLength'] ?? 0}",
                        subtitle: "Days",
                        valueColor: const Color(0xFFFF5252),
                      ),
                      TrackingStatCard(
                        title: "Total Period Logs",
                        value: "${data['totalPeriodLogs'] ?? 0}",
                        subtitle: "",
                        valueColor: const Color(0xFF9C27B0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildCycleLengthChart(data['cycleDistribution'] ?? {}),
                  _buildPeriodLengthChart(data['periodDistribution'] ?? {}),
                  _buildStartDayChart(data['startDayDistribution'] ?? {}),
                ],
              ),
            ),
    );
  }

  Widget _buildCycleLengthChart(Map<String, dynamic> distribution) {
    final labels = distribution.keys.toList();
    final values = distribution.values.map<double>((v) => (v as num).toDouble()).toList();
    return ChartContainer(
      title: "Cycle Length Distribution (Users)",
      child: _buildBarChart(labels, values, const Color(0xFFFF5252), 40),
    );
  }

  Widget _buildPeriodLengthChart(Map<String, dynamic> distribution) {
    final labels = distribution.keys.toList();
    final values = distribution.values.map<double>((v) => (v as num).toDouble()).toList();
    return ChartContainer(
      title: "Period Length Distribution (Users)",
      child: _buildBarChart(labels, values, const Color(0xFFFF5252), 30),
    );
  }

  Widget _buildStartDayChart(Map<dynamic, dynamic> distribution) {
    final Map<int, String> dayNames = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};
    final labels = dayNames.values.toList();
    final values = dayNames.keys.map<double>((k) => (distribution[k] ?? 0).toDouble()).toList();
    
    return ChartContainer(
      title: "Period Start Day [Week]",
      child: _buildBarChart(labels, values, const Color(0xFF9B7FE8), 20),
    );
  }

  Widget _buildBarChart(List<String> labels, List<double> values, Color color, double width) {
    if (values.isEmpty) return const SizedBox();
    
    double maxY = values.reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 100;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY + 10,
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
                if (i < 0 || i >= labels.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(labels[i], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: color,
                width: width,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }),
      ),
    );
  }
}
