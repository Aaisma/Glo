import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../model/tracker_theme.dart';
import '../../viewmodel/period_view_model.dart';
import '../../viewmodel/ovulation_view_model.dart';

class UnifiedDailyLog {
  final DateTime date;
  final bool isPeriodDay;
  final bool isOvulationDay;
  final bool isFertileWindow;
  final double? bbt;
  final String? flow;
  final String? sexDrive;
  final String? note;

  UnifiedDailyLog({
    required this.date,
    this.isPeriodDay = false,
    this.isOvulationDay = false,
    this.isFertileWindow = false,
    this.bbt,
    this.flow,
    this.sexDrive,
    this.note,
  });
}

class DailyLogHistoryPage extends StatelessWidget {
  final ThemeColors theme;
  const DailyLogHistoryPage({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final periodViewModel = context.watch<PeriodViewModel>();
    final ovulationViewModel = context.watch<OvulationViewModel>();

    final Map<String, UnifiedDailyLog> combinedLogs = {};
    
    for (var log in periodViewModel.logs) {
      final key = DateFormat('yyyy-MM-dd').format(log.date);
      combinedLogs[key] = UnifiedDailyLog(
        date: log.date,
        isPeriodDay: log.isPeriodDay,
        bbt: log.bbt,
        flow: log.flow,
        note: log.note,
      );
    }
    
    for (var log in ovulationViewModel.logs) {
      final key = DateFormat('yyyy-MM-dd').format(log.date);
      if (combinedLogs.containsKey(key)) {
        final existing = combinedLogs[key]!;
        combinedLogs[key] = UnifiedDailyLog(
          date: existing.date,
          isPeriodDay: existing.isPeriodDay,
          isOvulationDay: log.isOvulationDay,
          isFertileWindow: log.isFertileWindow,
          bbt: existing.bbt ?? log.bbt,
          flow: existing.flow,
          sexDrive: log.sexDrive,
          note: (existing.note != null && existing.note!.isNotEmpty) ? existing.note : log.note,
        );
      } else {
        combinedLogs[key] = UnifiedDailyLog(
          date: log.date,
          isOvulationDay: log.isOvulationDay,
          isFertileWindow: log.isFertileWindow,
          bbt: log.bbt,
          sexDrive: log.sexDrive,
          note: log.note,
        );
      }
    }

    final sortedLogs = combinedLogs.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.headerText),
        title: Text(
          "Daily Log History",
          style: TextStyle(
            color: theme.headerText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: sortedLogs.isEmpty
          ? const Center(child: Text("No logs found."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedLogs.length,
              itemBuilder: (context, index) {
                final log = sortedLogs[index];
                return _buildLogCard(log);
              },
            ),
    );
  }

  Widget _buildLogCard(UnifiedDailyLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, MMM dd, yyyy').format(log.date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.headerText,
                ),
              ),
              Row(
                children: [
                  if (log.isPeriodDay)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE94B64),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Period",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (log.isOvulationDay)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Ovulation",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (log.bbt != null)
                _buildInfoChip(Icons.thermostat, "${log.bbt!.toStringAsFixed(1)}°F"),
              if (log.flow != null && log.flow!.isNotEmpty)
                _buildInfoChip(Icons.water_drop, log.flow!),
              if (log.sexDrive != null && log.sexDrive!.isNotEmpty)
                _buildInfoChip(Icons.favorite, log.sexDrive!),
            ],
          ),
          if (log.note != null && log.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              "Notes:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              log.note!,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.lightCircle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.headerText),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.headerText),
          ),
        ],
      ),
    );
  }
}
