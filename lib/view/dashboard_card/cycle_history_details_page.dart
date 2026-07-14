import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/cycle_analytics_engine.dart';
import '../../model/tracker_theme.dart';
import 'cycle_details_view.dart';

class CycleHistoryDetailsPage extends StatefulWidget {
  final List<CycleData> pastCycles;
  final CycleData? currentCycle;
  final DateTime? lastPeriodStartDate;
  final int currentCycleDay;
  final ThemeColors theme;

  const CycleHistoryDetailsPage({
    super.key,
    required this.pastCycles,
    this.currentCycle,
    this.lastPeriodStartDate,
    required this.currentCycleDay,
    required this.theme,
  });

  @override
  State<CycleHistoryDetailsPage> createState() => _CycleHistoryDetailsPageState();
}

class _CycleHistoryDetailsPageState extends State<CycleHistoryDetailsPage> {
  String selectedFilter = "Last 6 cycles";

  @override
  Widget build(BuildContext context) {
    List<CycleData> displayCycles = widget.pastCycles.reversed.toList();
    if (selectedFilter == "Last 3 cycles") {
      displayCycles = displayCycles.take(3).toList();
    } else if (selectedFilter == "Last 6 cycles") {
      displayCycles = displayCycles.take(6).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cycle history",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildLegend(),
                const SizedBox(height: 16),
                _buildCycleList(displayCycles),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ["All", "Last 3 cycles", "Last 6 cycles"];
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => selectedFilter = filter);
              },
              selectedColor: const Color(0xFFFD8CA1),
              backgroundColor: const Color(0xFFF0F0F0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildLegendItem(const Color(0xFFFD8CA1), "Period"),
        const SizedBox(width: 16),
        _buildLegendItem(const Color(0xFFC8F2C4), "Fertile window"),
        const SizedBox(width: 16),
        _buildLegendItem(const Color(0xFF4CAF50), "Ovulation"),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildCycleList(List<CycleData> pastCycles) {
    // Group by year
    final Map<int, List<dynamic>> groupedByYear = {};

    // Add current cycle if filter matches
    if (widget.currentCycle != null) {
      final year = widget.currentCycle!.startDate.year;
      groupedByYear.putIfAbsent(year, () => []);
      groupedByYear[year]!.add(widget.currentCycle!);
    }

    for (var cycle in pastCycles) {
      final year = cycle.startDate.year;
      groupedByYear.putIfAbsent(year, () => []);
      groupedByYear[year]!.add(cycle);
    }

    final sortedYears = groupedByYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedYears.expand((year) {
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "$year",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: groupedByYear[year]!.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == groupedByYear[year]!.length - 1;

                Widget card;
                if (item is CycleData && item == widget.currentCycle) {
                  card = _buildCurrentCycleCard(item);
                } else {
                  card = _buildPastCycleCard(item as CycleData);
                }

                return Column(
                  children: [
                    card,
                    if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ];
      }).toList(),
    );
  }

  Widget _buildCurrentCycleCard(CycleData cycle) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      title: Text(
        "Current cycle: Day ${widget.currentCycleDay}",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            "Started ${DateFormat('MMM dd').format(cycle.startDate)}",
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _buildDotsRow(
            startDate: cycle.startDate,
            length: widget.currentCycleDay,
            periodDays: cycle.periodDays,
            fertileDays: cycle.fertileDays,
            ovulationDate: cycle.ovulationDate,
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CycleDetailsView(cycle: cycle, isCurrent: true),
          ),
        );
      },
    );
  }

  Widget _buildPastCycleCard(CycleData cycle) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      title: Text(
        "${cycle.lengthInDays} days",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            "${DateFormat('MMM dd').format(cycle.startDate)} – ${DateFormat('MMM dd').format(cycle.endDate)}",
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _buildDotsRow(
            startDate: cycle.startDate,
            length: cycle.lengthInDays,
            periodDays: cycle.periodDays,
            fertileDays: cycle.fertileDays,
            ovulationDate: cycle.ovulationDate,
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CycleDetailsView(cycle: cycle),
          ),
        );
      },
    );
  }

  Widget _buildDotsRow({
    required DateTime startDate,
    required int length,
    required List<DateTime> periodDays,
    required List<DateTime> fertileDays,
    required DateTime? ovulationDate,
  }) {
    // We'll show up to 35 dots or length, whichever is smaller to keep it one line if possible
    final displayLength = length.clamp(1, 35);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(displayLength, (index) {
          final date = startDate.add(Duration(days: index));
          
          Color dotColor = const Color(0xFFEEEEEE);
          
          bool isPeriod = periodDays.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
          bool isFertile = fertileDays.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
          bool isOvulation = ovulationDate != null && ovulationDate.year == date.year && ovulationDate.month == date.month && ovulationDate.day == date.day;

          if (isOvulation) {
            dotColor = const Color(0xFF4CAF50);
          } else if (isPeriod) {
            dotColor = const Color(0xFFFD8CA1);
          } else if (isFertile) {
            dotColor = const Color(0xFFC8F2C4);
          }

          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
