import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../model/tracker_theme.dart';
import '../../viewmodel/period_view_model.dart';
import '../../viewmodel/ovulation_view_model.dart';
import '../../model/cycle_analytics_engine.dart';

class AnalyticsHistoryPage extends StatefulWidget {
  final ThemeColors theme;
  const AnalyticsHistoryPage({super.key, required this.theme});

  @override
  State<AnalyticsHistoryPage> createState() => _AnalyticsHistoryPageState();
}

class _AnalyticsHistoryPageState extends State<AnalyticsHistoryPage> {
  @override
  Widget build(BuildContext context) {
    // Both viewmodel provide equivalent calculations since they both run CycleAnalyticsEngine
    final periodViewModel = context.watch<PeriodViewModel>();
    final analytics = periodViewModel.analyticsResult;

    if (analytics == null) {
      return Scaffold(
        backgroundColor: widget.theme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: widget.theme.headerText),
          title: const Text("Analytics & History", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: widget.theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: widget.theme.headerText),
        title: Text(
          "Cycle History & Analytics",
          style: TextStyle(
            color: widget.theme.headerText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricGrid(analytics),
            const SizedBox(height: 20),
            _buildCycleHistoryList(analytics),
            const SizedBox(height: 20),
            _buildChartsSection(analytics),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricGrid(CycleAnalyticsResult analytics) {
    final metrics = [
      {"label": "Avg Cycle Length", "value": "${analytics.averageCycleLength} Days", "icon": Icons.loop, "color": widget.theme.headerText},
      {"label": "Avg Period Length", "value": "${analytics.averagePeriodLength} Days", "icon": Icons.water_drop, "color": const Color(0xFFE94B64)},
      {"label": "Regularity", "value": "${analytics.regularityPercentage}%", "icon": Icons.insights, "color": Colors.purple},
      {"label": "Current Cycle Day", "value": "Day ${analytics.currentCycleDay}", "icon": Icons.calendar_today, "color": widget.theme.headerText},
      {"label": "Avg Ovulation Day", "value": "Day ${analytics.averageOvulationDay}", "icon": Icons.star, "color": const Color(0xFF4CAF50)},
      {"label": "Shortest Cycle", "value": "${analytics.shortestCycle} Days", "icon": Icons.trending_down, "color": Colors.blue},
      {"label": "Longest Cycle", "value": "${analytics.longestCycle} Days", "icon": Icons.trending_up, "color": Colors.red},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final m = metrics[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.theme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(m["icon"] as IconData, color: m["color"] as Color, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      m["label"] as String,
                      style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                m["value"] as String,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCycleHistoryList(CycleAnalyticsResult analytics) {
    // Take last 6 cycles
    final cycles = analytics.pastCycles.reversed.take(6).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.theme.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Last 6 Cycles Summary",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 16),
          if (cycles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  "No past cycles logged yet.",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ),
          ...cycles.map((c) => _buildCycleVisualizationRow(c)),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(const Color(0xFFE94B64), "Period"),
              _buildLegendItem(const Color(0xFFC8F2C4), "Fertile Window"),
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                    child: const Icon(Icons.star, size: 10, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Text("Ovulation Day", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              _buildLegendItem(const Color(0xFFEEEEEE), "Normal Day"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCycleVisualizationRow(CycleData cycle) {
    final blocks = <Widget>[];
    
    // Create a square representation for each day of the cycle up to cycle.lengthInDays
    for (int day = 1; day <= cycle.lengthInDays; day++) {
      final date = cycle.startDate.add(Duration(days: day - 1));
      
      Color blockColor = const Color(0xFFEEEEEE);
      Widget? centerIcon;

      final isPeriod = cycle.periodDays.contains(date);
      final isOvulation = cycle.ovulationDate != null && 
          cycle.ovulationDate!.year == date.year &&
          cycle.ovulationDate!.month == date.month &&
          cycle.ovulationDate!.day == date.day;
      final isFertile = cycle.fertileDays.contains(date);

      if (isOvulation) {
        blockColor = const Color(0xFF4CAF50);
        centerIcon = const Icon(Icons.star, size: 8, color: Colors.white);
      } else if (isPeriod) {
        blockColor = const Color(0xFFE94B64);
      } else if (isFertile) {
        blockColor = const Color(0xFFC8F2C4);
      }

      blocks.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: blockColor,
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
            child: centerIcon,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Cycle ${cycle.number}",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                "${cycle.lengthInDays} Days",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: blocks),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(CycleAnalyticsResult analytics) {
    final pastCycles = analytics.pastCycles;
    if (pastCycles.length < 2) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.theme.border),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              "Log at least 2 cycles to see trend charts.",
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
        ),
      );
    }

    final cycleLabels = pastCycles.map((c) => "C${c.number}").toList();
    
    // Cycle length data points
    final cycleLengths = pastCycles.map((c) => c.lengthInDays.toDouble()).toList();
    // Period length data points
    final periodLengths = pastCycles.map((c) => c.periodLength.toDouble()).toList();
    // Ovulation day offset data points
    final ovulationDays = pastCycles
        .map((c) => (c.ovulationDate!.difference(c.startDate).inDays + 1).toDouble())
        .toList();

    return Column(
      children: [
        _buildChartCard("Cycle Length Trend", cycleLengths, cycleLabels, widget.theme.headerText),
        const SizedBox(height: 16),
        _buildChartCard("Period Length Trend", periodLengths, cycleLabels, const Color(0xFFE94B64)),
        const SizedBox(height: 16),
        _buildChartCard("Ovulation Day Trend", ovulationDays, cycleLabels, const Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _buildChartCard(String title, List<double> data, List<String> labels, Color lineColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.theme.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: CustomLineChart(
              data: data,
              labels: labels,
              lineColor: lineColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomLineChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final Color lineColor;

  const CustomLineChart({
    super.key,
    required this.data,
    required this.labels,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double valueRange = maxVal - minVal;
    
    final double minY = (minVal - 1.0).clamp(0, double.infinity);
    final double maxY = maxVal + 1.0;

    final List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: valueRange == 0 ? 1 : (valueRange / 3).clamp(1, double.infinity),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.15),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 9,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      labels[index],
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 9,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: lineColor,
                  strokeWidth: 2.5,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  lineColor.withValues(alpha: 0.3),
                  lineColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
