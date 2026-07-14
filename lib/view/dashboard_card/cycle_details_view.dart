import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../model/cycle_analytics_engine.dart';
import '../../viewmodel/period_view_model.dart';
import '../../model/period_log_model.dart';

class CycleDetailsView extends StatelessWidget {
  final CycleData cycle;
  final bool isCurrent;

  const CycleDetailsView({
    super.key,
    required this.cycle,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final periodViewModel = context.watch<PeriodViewModel>();
    final allLogs = periodViewModel.logs;

    // Filter logs that belong to this cycle
    final cycleLogs = allLogs.where((log) {
      final date = DateTime(log.date.year, log.date.month, log.date.day);
      return date.isAfter(cycle.startDate.subtract(const Duration(days: 1))) &&
             date.isBefore(cycle.endDate.add(const Duration(days: 1)));
    }).toList();
    cycleLogs.sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isCurrent ? "Current Cycle" : "Cycle ${cycle.number}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildCycleSummaryHeader(cycle),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final log = cycleLogs[index];
                  return _buildDailyLogCard(log, cycle);
                },
                childCount: cycleLogs.length,
              ),
            ),
          ),
          if (cycleLogs.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  "No daily logs recorded for this cycle.",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCycleSummaryHeader(CycleData cycle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStat("${cycle.lengthInDays}", "Days Total"),
              _buildSummaryStat("${cycle.periodLength}", "Period Days"),
              _buildSummaryStat(
                cycle.ovulationDate != null 
                  ? "${cycle.ovulationDate!.difference(cycle.startDate).inDays + 1}" 
                  : "-", 
                "Ovulation Day"
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "${DateFormat('MMMM dd').format(cycle.startDate)} – ${DateFormat('MMMM dd').format(cycle.endDate)}",
            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFD8CA1)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildDailyLogCard(PeriodLogModel log, CycleData cycle) {
    final bool isPeriod = cycle.periodDays.any((d) => _isSameDay(d, log.date));
    final bool isOvulation = cycle.ovulationDate != null && _isSameDay(cycle.ovulationDate!, log.date);
    final bool isFertile = cycle.fertileDays.any((d) => _isSameDay(d, log.date));

    Color statusColor = Colors.transparent;
    String statusText = "";
    if (isOvulation) {
      statusColor = const Color(0xFF4CAF50);
      statusText = "Ovulation Day";
    } else if (isPeriod) {
      statusColor = const Color(0xFFFD8CA1);
      statusText = "Period";
    } else if (isFertile) {
      statusColor = const Color(0xFFC8F2C4);
      statusText = "Fertile Window";
    }

    final symptoms = log.symptoms.entries.where((e) => e.value).map((e) => e.key).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM dd').format(log.date),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (statusText.isNotEmpty)
                          Text(
                            statusText,
                            style: TextStyle(
                              color: isOvulation ? const Color(0xFF4CAF50) : (isPeriod ? const Color(0xFFFD8CA1) : Colors.black45),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    if (log.flow != null || symptoms.isNotEmpty || log.note != null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                    if (log.flow != null)
                      _buildLogSection("Flow", log.flow!),
                    if (symptoms.isNotEmpty)
                      _buildLogSection("Symptoms", symptoms.join(", ")),
                    if (log.note != null && log.note!.isNotEmpty)
                      _buildLogSection("Note", log.note!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
