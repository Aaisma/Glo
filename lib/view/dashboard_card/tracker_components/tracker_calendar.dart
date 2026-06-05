import 'package:flutter/material.dart';
import '../../../model/tracker_theme.dart';
import '../../../viewmodel/ovulation_view_model.dart';

class TrackerCalendar extends StatelessWidget {
  final OvulationViewModel viewModel;
  final ThemeColors theme;

  const TrackerCalendar({super.key, required this.viewModel, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: viewModel.isPeriodTracker ? const Color(0xFFFCF2F4) : const Color(0xFFF1F8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            "April 2024",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.headerText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map((day) {
              return Text(
                day,
                style: TextStyle(color: theme.headerText, fontWeight: FontWeight.bold, fontSize: 12),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 35, // 5 weeks
            itemBuilder: (context, index) {
              if (index == 0) return const SizedBox.shrink(); // Sun
              int dayNumber = index;
              if (dayNumber > 30) return const SizedBox.shrink();

              Color bgColor = Colors.transparent;
              Color textColor = Colors.black87;

              if (viewModel.isPeriodTracker) {
                if (dayNumber == 7) {
                  bgColor = theme.lightCircle;
                  textColor = theme.headerText;
                } else if (dayNumber >= 8 && dayNumber <= 13) {
                  bgColor = theme.darkCircle;
                  textColor = Colors.white;
                } else if (dayNumber >= 14 && dayNumber <= 19) {
                  bgColor = const Color(0xFFFDE4E8);
                  textColor = theme.headerText;
                } else if (dayNumber == 22 || dayNumber == 27) {
                  bgColor = const Color(0xFFFDE4E8);
                  textColor = theme.headerText;
                }
              } else {
                if (dayNumber >= 7 && dayNumber <= 16 && dayNumber != 11) {
                  bgColor = theme.lightCircle;
                  textColor = Colors.white;
                } else if (dayNumber == 11) {
                  bgColor = theme.darkCircle;
                  textColor = Colors.white;
                } else if (dayNumber == 20 || dayNumber == 27 || dayNumber == 25) {
                  bgColor = theme.lightCircle;
                  textColor = theme.headerText;
                }
              }

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  dayNumber.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: bgColor != Colors.transparent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
