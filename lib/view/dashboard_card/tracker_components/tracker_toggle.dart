import 'package:flutter/material.dart';
import '../../../model/tracker_theme.dart';
import '../../../viewmodel/ovulation_view_model.dart';

class TrackerToggle extends StatelessWidget {
  final OvulationViewModel viewModel;
  final ThemeColors theme;

  const TrackerToggle({super.key, required this.viewModel, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: viewModel.isPeriodTracker ? const Color(0xFFFCE1E6) : const Color(0xFFDAF0D6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => viewModel.toggleTracker(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: viewModel.isPeriodTracker ? periodTheme.toggleActiveBg : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(Icons.water_drop, color: viewModel.isPeriodTracker ? Colors.white : periodTheme.headerText, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "Period",
                    style: TextStyle(
                      color: viewModel.isPeriodTracker ? Colors.white : periodTheme.headerText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => viewModel.toggleTracker(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: !viewModel.isPeriodTracker ? ovulationTheme.toggleActiveBg : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: !viewModel.isPeriodTracker ? Colors.white : ovulationTheme.headerText, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "Ovulation",
                    style: TextStyle(
                      color: !viewModel.isPeriodTracker ? Colors.white : ovulationTheme.headerText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
