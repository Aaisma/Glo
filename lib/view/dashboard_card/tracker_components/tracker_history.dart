import 'package:flutter/material.dart';
import '../../../model/tracker_theme.dart';
import '../../../viewmodel/ovulation_view_model.dart';

class TrackerHistory extends StatelessWidget {
  final OvulationViewModel viewModel;
  final ThemeColors theme;

  const TrackerHistory({super.key, required this.viewModel, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note, color: theme.headerText),
              const SizedBox(width: 8),
              Text(
                "Cycle History",
                style: TextStyle(
                  color: theme.headerText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (viewModel.isPeriodTracker) ...[
            _buildHistoryRow(
              date: "Mar 12 - Mar 17, 2024",
              duration: "6 Days",
              flow: "Heavy Flow",
              extra: "Days • Heavy Flow",
            ),
            const SizedBox(height: 12),
            _buildHistoryRow(
              date: "Feb 8 - Feb 13, 2024",
              duration: "6 Days",
              flow: "Medium Flow",
              extra: "Days • Medium Flow",
            ),
          ] else ...[
            _buildHistoryRow(
              date: "Ovulation: Apr 19, 2024",
              duration: "Fertile Window: Mar 17 - Apr 21",
              flow: "",
              extra: "Days • Heavy Flow",
            ),
            const SizedBox(height: 12),
            _buildHistoryRow(
              date: "Ovulation: Mar 25, 2024",
              duration: "Fertile Window: Mar 20 - Apr 26",
              flow: "",
              extra: "Days • Medium Flow",
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryRow({
    required String date,
    required String duration,
    required String flow,
    required String extra,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(
                flow.isNotEmpty ? "$duration • $flow" : duration,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ],
          ),
        ),
        Icon(Icons.circle, color: theme.darkCircle, size: 10),
        const SizedBox(width: 4),
        Text(extra, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
