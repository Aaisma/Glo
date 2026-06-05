import 'package:flutter/material.dart';
import '../../../model/tracker_theme.dart';
import '../../../viewmodel/ovulation_view_model.dart';

class TrackerSymptoms extends StatelessWidget {
  final OvulationViewModel viewModel;
  final ThemeColors theme;

  const TrackerSymptoms({super.key, required this.viewModel, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOtherSymptomsButton(),
        const SizedBox(height: 12),
        _buildSymptomCards(),
        const SizedBox(height: 12),
        _buildLogButtons(),
      ],
    );
  }

  Widget _buildOtherSymptomsButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
      ),
      child: Center(
        child: Text(
          "Other Symptoms >",
          style: TextStyle(
            color: theme.headerText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomCards() {
    final items = viewModel.isPeriodTracker
        ? [
            {"icon": Icons.water_drop, "label": "Flow\nCramps", "color": Colors.red},
            {"icon": Icons.air, "label": "Bloating\nTenderness", "color": Colors.redAccent},
            {"icon": Icons.airline_seat_flat, "label": "Fatigue", "color": Colors.red},
            {"icon": Icons.favorite, "label": "Breast\nTenderness", "color": Colors.redAccent},
          ]
        : [
            {"icon": Icons.water_drop, "label": "Cervical\nMucus", "color": Colors.green},
            {"icon": Icons.health_and_safety, "label": "Ovulation\nPain", "color": Colors.red},
            {"icon": Icons.favorite, "label": "Libido", "color": Colors.redAccent},
            {"icon": Icons.thermostat, "label": "Basal Body\nTemp", "color": Colors.green},
          ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: viewModel.isPeriodTracker ? const Color(0xFFFCF2F4) : const Color(0xFFF1F8F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item["icon"] as IconData, color: item["color"] as Color, size: 28),
                const SizedBox(height: 4),
                Text(
                  item["label"] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.water_drop_outlined, color: theme.headerText, size: 18),
                const SizedBox(width: 4),
                const Text("Log BBT", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color: theme.headerText, size: 18),
                const SizedBox(width: 4),
                Text(viewModel.isPeriodTracker ? "Log Flow" : "Log Sex Drive", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
