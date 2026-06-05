import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/ovulation_view_model.dart';
import 'tracker_components/tracker_toggle.dart';
import 'tracker_components/tracker_calendar.dart';
import 'tracker_components/tracker_symptoms.dart';
import 'tracker_components/tracker_history.dart';
import 'tracker_components/tracker_notes.dart';

class OvulationPage extends StatelessWidget {
  const OvulationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the ViewModel to the view
    return ChangeNotifierProvider(
      create: (_) => OvulationViewModel(),
      child: const OvulationView(),
    );
  }
}

class OvulationView extends StatelessWidget {
  const OvulationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the view model
    final viewModel = context.watch<OvulationViewModel>();
    final theme = viewModel.currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.headerText),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TrackerToggle(viewModel: viewModel, theme: theme),
              const SizedBox(height: 16),
              Text(
                viewModel.isPeriodTracker ? "Period Tracker" : "Ovulation Tracker",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.headerText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                viewModel.isPeriodTracker ? "Track your menstrual cycle" : "Track your fertile window",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: theme.border, width: double.infinity),
              const SizedBox(height: 16),
              TrackerCalendar(viewModel: viewModel, theme: theme),
              const SizedBox(height: 12),
              TrackerSymptoms(viewModel: viewModel, theme: theme),
              const SizedBox(height: 12),
              TrackerHistory(viewModel: viewModel, theme: theme),
              const SizedBox(height: 12),
              TrackerNotes(theme: theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
