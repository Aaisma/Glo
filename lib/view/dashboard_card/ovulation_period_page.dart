import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repo/period_repo_impl.dart';
import '../../repo/ovulation_repo_impl.dart';
import '../../viewmodel/tracker_navigation_view_model.dart';
import '../../viewmodel/period_view_model.dart';
import '../../viewmodel/ovulation_view_model.dart';
import 'period_tracker.dart';
import 'ovulation_tracker.dart';

class OvulationPage extends StatelessWidget {
  const OvulationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrackerNavigationViewModel()),
        ChangeNotifierProvider(create: (_) => PeriodViewModel(PeriodRepoImpl())),
        ChangeNotifierProvider(create: (_) => OvulationViewModel(OvulationRepoImpl())),
      ],
      child: const OvulationView(),
    );
  }
}

class OvulationView extends StatelessWidget {
  const OvulationView({super.key});

  @override
  Widget build(BuildContext context) {
    final navViewModel = context.watch<TrackerNavigationViewModel>();
    final theme = navViewModel.currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNavigation(context, navViewModel),
            Expanded(
              child: navViewModel.isPeriodTracker
                  ? const PeriodTrackerView()
                  : const OvulationTrackerView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation(BuildContext context, TrackerNavigationViewModel navViewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            icon: Icon(Icons.arrow_back, color: navViewModel.currentTheme.headerText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          
          // Toggle Switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: navViewModel.currentTheme.border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => navViewModel.toggleTracker(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: navViewModel.isPeriodTracker ? const Color(0xFFFD8CA1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      "Period",
                      style: TextStyle(
                        color: navViewModel.isPeriodTracker ? Colors.white : const Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => navViewModel.toggleTracker(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: !navViewModel.isPeriodTracker ? const Color(0xFFA8E6A1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      "Ovulation",
                      style: TextStyle(
                        color: !navViewModel.isPeriodTracker ? Colors.white : const Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Cycle History Shortcut
          IconButton(
            icon: Icon(Icons.history, color: navViewModel.currentTheme.headerText),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cycle History coming soon!')));
            },
          ),
        ],
      ),
    );
  }
}
