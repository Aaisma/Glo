import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/tracker_navigation_view_model.dart';
import '../../viewmodel/period_view_model.dart';
import '../../viewmodel/ovulation_view_model.dart';
import 'period_tracker.dart';
import 'ovulation_tracker.dart';
import 'daily_history_page.dart';
import 'analytics_history_page.dart';

class OvulationPage extends StatelessWidget {
  const OvulationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackerNavigationViewModel(),
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
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left: Back Button
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: navViewModel.currentTheme.headerText),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            
            // Center: Toggle Switch
            Align(
              alignment: Alignment.center,
              child: Container(
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
            ),
            
            // Right: Navigation Icons (Analytics & Daily History)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.bar_chart_rounded, color: navViewModel.currentTheme.headerText),
                    tooltip: "Analytics & Cycle History",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => MultiProvider(
                            providers: [
                              ChangeNotifierProvider.value(value: context.read<PeriodViewModel>()),
                              ChangeNotifierProvider.value(value: context.read<OvulationViewModel>()),
                            ],
                            child: AnalyticsHistoryPage(theme: navViewModel.currentTheme),
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.history_rounded, color: navViewModel.currentTheme.headerText),
                    tooltip: "Daily Log History",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => MultiProvider(
                            providers: [
                              ChangeNotifierProvider.value(value: context.read<PeriodViewModel>()),
                              ChangeNotifierProvider.value(value: context.read<OvulationViewModel>()),
                            ],
                            child: DailyHistoryPage(theme: navViewModel.currentTheme),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
