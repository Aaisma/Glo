import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/admin_monthly_tracking_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glo/view/dashboard_card/admin/components/admin_tracking_components.dart';

class AdminOvulationAnalyticsScreen extends StatelessWidget {
  const AdminOvulationAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminMonthlyTrackingViewModel>();
    final data = vm.ovulationAnalytics;
    final isLoading = vm.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const AdminTrackingAppBar(title: "Ovulation Analytics"),
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
                        title: "Avg Ovulation Day",
                        value: "${data['avgOvulationDay'] ?? 0}",
                        subtitle: "Days",
                        valueColor: const Color(0xFF4CAF50),
                      ),
                      TrackingStatCard(
                        title: "Fertile Window (Avg)",
                        value: "${data['avgFertileWindow'] ?? 0}",
                        subtitle: "Days",
                        valueColor: const Color(0xFF4CAF50),
                      ),
                      TrackingStatCard(
                        title: "Total Ovulation Logs",
                        value: "${data['totalOvulationLogs'] ?? 0}",
                        subtitle: "",
                        valueColor: Colors.black87,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildOvulationDayChart(data['ovulationDistribution'] ?? {}),
                  _buildFertileWindowChart(data['fertileWindowDistribution'] ?? {}),
                  _buildAccuracyChart(data['accuracy'] ?? {}),
                ],
              ),
            ),
    );
  }

  Widget _buildOvulationDayChart(Map<String, dynamic> distribution) {
    final labels = distribution.keys.toList();
    final values = distribution.values.map<double>((v) => (v as num).toDouble()).toList();
    return ChartContainer(
      title: "Ovulation Day Distribution (Users)",
      child: _buildBarChart(labels, values, const Color(0xFF66BB6A), 40),
    );
  }

  Widget _buildFertileWindowChart(Map<String, dynamic> distribution) {
    final labels = distribution.keys.toList();
    final values = distribution.values.map<double>((v) => (v as num).toDouble()).toList();
    return ChartContainer(
      title: "Fertile Window Distribution (Users)",
      child: _buildBarChart(labels, values, const Color(0xFF66BB6A), 30),
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

  Widget _buildAccuracyChart(Map<String, dynamic> accuracy) {
    final accurate = (accuracy['Accurate'] ?? 0).toDouble();
    final inaccurate = (accuracy['Inaccurate'] ?? 0).toDouble();
    
    return ChartContainer(
      title: "Ovulation Accuracy (vs. Actual Logs)",
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: const Color(0xFF66BB6A),
                          value: accurate,
                          title: '',
                          radius: 12,
                        ),
                        PieChartSectionData(
                          color: const Color(0xFFFF5252),
                          value: inaccurate,
                          title: '',
                          radius: 12,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${accurate.toInt()}%", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text("Accurate", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF66BB6A), "Accurate", "${accurate.toInt()}%"),
                const SizedBox(height: 12),
                _buildLegendItem(const Color(0xFFFF5252), "Inaccurate", "${inaccurate.toInt()}%"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
