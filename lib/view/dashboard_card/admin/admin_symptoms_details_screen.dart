import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/admin_monthly_tracking_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glo/view/dashboard_card/admin/components/admin_tracking_components.dart';

class AdminSymptomsDetailsScreen extends StatelessWidget {
  const AdminSymptomsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminMonthlyTrackingViewModel>();
    final data = vm.symptomsDetails;
    final isLoading = vm.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const AdminTrackingAppBar(title: "Symptoms Details"),
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
                  _buildDropdownSelector(context, vm),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TrackingStatCard(
                        title: "Total Logs",
                        value: "${data['totalLogs'] ?? 0}",
                        subtitle: "",
                        valueColor: const Color(0xFF2196F3),
                      ),
                      TrackingStatCard(
                        title: "Users",
                        value: "${data['users'] ?? 0}",
                        subtitle: "",
                        valueColor: Colors.black87,
                      ),
                      TrackingStatCard(
                        title: "% of All Logs",
                        value: "${data['percentageOfAllLogs'] ?? 0}%",
                        subtitle: "",
                        valueColor: Colors.black87,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildByPhaseChart(vm.selectedSymptom, data['byCyclePhase'] ?? {}),
                  _buildIntensityChart(vm.selectedSymptom, data['intensity'] ?? {}),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdownSelector(BuildContext context, AdminMonthlyTrackingViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text("Selected Symptom", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: vm.selectedSymptom,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: vm.availableSymptoms.map((String symptom) {
                return DropdownMenuItem<String>(
                  value: symptom,
                  child: Text(symptom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  vm.setSelectedSymptom(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildByPhaseChart(String symptom, Map<String, dynamic> phases) {
    final reversedPhases = phases.entries.toList().reversed.toList();
    
    return ChartContainer(
      title: "$symptom by Cycle Phase (Users)",
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= reversedPhases.length) return const SizedBox();
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text("${reversedPhases[i].value}%", style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
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
                  if (i < 0 || i >= reversedPhases.length) return const SizedBox();
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(reversedPhases[i].key, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(reversedPhases.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (reversedPhases[i].value as num).toDouble(),
                  color: const Color(0xFF64B5F6),
                  width: 10,
                  borderRadius: BorderRadius.circular(2),
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

  Widget _buildIntensityChart(String symptom, Map<String, dynamic> intensity) {
    // Expected to be Mild, Moderate, Severe
    final labels = ['Severe', 'Moderate', 'Mild'];
    final values = [
      (intensity['Severe'] ?? 0).toDouble(),
      (intensity['Moderate'] ?? 0).toDouble(),
      (intensity['Mild'] ?? 0).toDouble()
    ];
    
    return ChartContainer(
      title: "$symptom Intensity (Avg)",
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  if (values[i] == 0) return const SizedBox();
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text("${values[i].toInt()}%", style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(labels[i], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(labels.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: const Color(0xFF64B5F6),
                  width: 10,
                  borderRadius: BorderRadius.circular(2),
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
}
