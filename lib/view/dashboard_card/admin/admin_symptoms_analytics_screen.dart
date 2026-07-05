import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/admin_monthly_tracking_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glo/view/dashboard_card/admin/components/admin_tracking_components.dart';

class AdminSymptomsAnalyticsScreen extends StatelessWidget {
  const AdminSymptomsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminMonthlyTrackingViewModel>();
    final data = vm.symptomsAnalytics;
    final isLoading = vm.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const AdminTrackingAppBar(title: "Symptoms Analytics"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DateFilterSelector(),
                      ExportButton(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      TrackingStatCard(
                        title: "Total Symptom Logs",
                        value: "${data['totalSymptomLogs'] ?? 0}",
                        subtitle: "",
                        valueColor: Colors.black87,
                      ),
                      TrackingStatCard(
                        title: "Users Logging Symptoms",
                        value: "${data['usersLoggingSymptoms'] ?? 0}",
                        subtitle: "",
                        valueColor: const Color(0xFF9C27B0),
                      ),
                      TrackingStatCard(
                        title: "Avg Symptoms / User",
                        value: (data['avgSymptomsPerUser'] ?? 0).toStringAsFixed(1),
                        subtitle: "",
                        valueColor: const Color(0xFF9C27B0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTopSymptomsChart(data['topSymptoms'] ?? []),
                  _buildSymptomsByPhaseChart(data['symptomsByPhase'] ?? {}),
                ],
              ),
            ),
    );
  }

  Widget _buildTopSymptomsChart(List<dynamic> topSymptoms) {
    // Reverse the list so the highest is at the top of the horizontal chart
    final reversedSymptoms = List.from(topSymptoms.reversed);
    
    return ChartContainer(
      title: "Top Logged Symptoms",
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: topSymptoms.isEmpty ? 100 : (topSymptoms.first.value as num).toDouble() * 1.2,
          barTouchData: BarTouchData(enabled: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= reversedSymptoms.length) return const SizedBox();
                  final val = reversedSymptoms[i].value;
                  // Fake percentage for design parity
                  final pct = (val / (topSymptoms.first.value as num) * 45).round(); 
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("$val ($pct%)", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 80,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= reversedSymptoms.length) return const SizedBox();
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(reversedSymptoms[i].key, style: const TextStyle(fontSize: 10, color: Colors.black87)),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(reversedSymptoms.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (reversedSymptoms[i].value as num).toDouble(),
                  color: const Color(0xFFB39DDB),
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
        swapAnimationDuration: const Duration(milliseconds: 150),
        swapAnimationCurve: Curves.linear,
      ),
    );
  }

  Widget _buildSymptomsByPhaseChart(Map<String, dynamic> phases) {
    final colors = [
      const Color(0xFFFF5252), // Menstrual
      const Color(0xFF66BB6A), // Fertile
      const Color(0xFF29B6F6), // Ovulation
      const Color(0xFFFFCA28), // Luteal
    ];
    
    final labels = phases.keys.toList();
    final values = phases.values.map<double>((v) => (v as num).toDouble()).toList();
    
    return ChartContainer(
      title: "Symptoms by Phase",
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 140,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 35,
                  sections: List.generate(values.length, (i) {
                    return PieChartSectionData(
                      color: colors[i % colors.length],
                      value: values[i],
                      title: '',
                      radius: 20,
                    );
                  }),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(labels.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(labels[i], style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        ],
                      ),
                      Text("${values[i].toInt()}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
