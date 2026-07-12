import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/admin_health_overview_viewmodel.dart';

class HealthOverviewScreen extends StatelessWidget {
  const HealthOverviewScreen({
    super.key,
    this.data,
  });

  final HealthOverviewData? data;

  /// Opens Health Overview from the admin dashboard while keeping the
  /// existing AdminHealthOverviewViewModel available on the new route.
  static Future<void> open(BuildContext context) {
    final viewModel = context.read<AdminHealthOverviewViewModel>();

    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: viewModel,
          child: const HealthOverviewScreen(),
        ),
      ),
    );
  }

  static const Color primaryBlue = Color(0xFF9BD8FA);
  static const Color deepBlue = Color(0xFF21475E);
  static const Color softBlue = Color(0xFFEFF9FF);
  static const Color cardBlue = Color(0xFFFAFDFF);
  static const Color bg = Color(0xFFF4FBFF);
  static const Color borderBlue = Color(0xFFDDF2FF);

  bool get hasData => data != null;

  @override
  Widget build(BuildContext context) {
    final overview = data ?? HealthOverviewData.empty();

    final cards = [
      StatCardData(
        title: "Active Users",
        value: overview.activeUsers.toString(),
        percent: overview.activeUsersChange,
        icon: Icons.people_outline,
        details: overview.activeUsersDetails,
      ),
      StatCardData(
        title: "Derma Visits",
        value: overview.totalVisits.toString(),
        percent: overview.visitsChange,
        icon: Icons.medical_services_outlined,
        details: overview.visitsDetails,
      ),
      StatCardData(
        title: "Treatments",
        value: overview.totalTreatments.toString(),
        percent: overview.treatmentsChange,
        icon: Icons.healing_outlined,
        details: overview.treatmentsDetails,
      ),
      StatCardData(
        title: "Reminders",
        value: overview.totalReminders.toString(),
        percent: overview.remindersChange,
        icon: Icons.notifications_none,
        details: overview.remindersDetails,
      ),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 22),

              Text(
                overview.dateRange,
                style: const TextStyle(
                  fontSize: 17,
                  color: deepBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),

              if (!hasData) ...[
                const SizedBox(height: 16),
                const _EmptyNotice(),
              ],

              const SizedBox(height: 22),

              GridView.builder(
                itemCount: cards.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: .95,
                ),
                itemBuilder: (_, index) {
                  return _StatCard(
                    data: cards[index],
                    enabled: hasData,
                  );
                },
              ),

              const SizedBox(height: 24),

              _ChartCard(hasData: hasData),

              const SizedBox(height: 24),

              _TopTreatmentsCard(
                treatments: overview.topTreatments,
                hasData: hasData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HealthOverviewData {
  final String dateRange;

  final int activeUsers;
  final int totalVisits;
  final int totalTreatments;
  final int totalReminders;

  final String activeUsersChange;
  final String visitsChange;
  final String treatmentsChange;
  final String remindersChange;

  final String activeUsersDetails;
  final String visitsDetails;
  final String treatmentsDetails;
  final String remindersDetails;

  final List<TreatmentStat> topTreatments;

  const HealthOverviewData({
    required this.dateRange,
    required this.activeUsers,
    required this.totalVisits,
    required this.totalTreatments,
    required this.totalReminders,
    required this.activeUsersChange,
    required this.visitsChange,
    required this.treatmentsChange,
    required this.remindersChange,
    required this.activeUsersDetails,
    required this.visitsDetails,
    required this.treatmentsDetails,
    required this.remindersDetails,
    required this.topTreatments,
  });

  factory HealthOverviewData.empty() {
    return const HealthOverviewData(
      dateRange: "No data available yet",
      activeUsers: 0,
      totalVisits: 0,
      totalTreatments: 0,
      totalReminders: 0,
      activeUsersChange: "0%",
      visitsChange: "0%",
      treatmentsChange: "0%",
      remindersChange: "0%",
      activeUsersDetails: "No user data has been added yet.",
      visitsDetails: "No visit data has been added yet.",
      treatmentsDetails: "No treatment data has been added yet.",
      remindersDetails: "No reminder data has been added yet.",
      topTreatments: [],
    );
  }
}

class TreatmentStat {
  final String name;
  final int count;

  const TreatmentStat({
    required this.name,
    required this.count,
  });
}

class StatCardData {
  final String title;
  final String value;
  final String percent;
  final IconData icon;
  final String details;

  const StatCardData({
    required this.title,
    required this.value,
    required this.percent,
    required this.icon,
    required this.details,
  });
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(
          Icons.health_and_safety_outlined,
          size: 42,
          color: HealthOverviewScreen.primaryBlue,
        ),
        SizedBox(width: 14),
        Expanded(
          child: Text(
            "Health Overview",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 27,
              color: HealthOverviewScreen.deepBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor: HealthOverviewScreen.softBlue,
          child: Icon(
            Icons.admin_panel_settings_outlined,
            color: HealthOverviewScreen.primaryBlue,
            size: 30,
          ),
        ),
      ],
    );
  }
}

class _EmptyNotice extends StatelessWidget {
  const _EmptyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: HealthOverviewScreen.primaryBlue,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "No user, treatment, visit, or reminder data yet. This dashboard will update automatically once real data is added.",
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: HealthOverviewScreen.deepBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.data,
    required this.enabled,
  });

  final StatCardData data;
  final bool enabled;

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: HealthOverviewScreen.cardBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Row(
          children: [
            Icon(
              data.icon,
              color: HealthOverviewScreen.primaryBlue,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                data.title,
                style: const TextStyle(
                  color: HealthOverviewScreen.deepBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          data.details,
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: HealthOverviewScreen.deepBlue,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDetails(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: HealthOverviewScreen.softBlue,
                  child: Icon(
                    data.icon,
                    color: HealthOverviewScreen.primaryBlue,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: HealthOverviewScreen.deepBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.value,
                  style: const TextStyle(
                    fontSize: 25,
                    color: HealthOverviewScreen.deepBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      data.percent,
                      style: const TextStyle(
                        color: HealthOverviewScreen.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        "vs last week",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.hasData});

  final bool hasData;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Center(
        child: Text(
          hasData
              ? "Weekly health activity chart"
              : "Chart will appear when health data is added",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: HealthOverviewScreen.deepBlue,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TopTreatmentsCard extends StatelessWidget {
  const _TopTreatmentsCard({
    required this.treatments,
    required this.hasData,
  });

  final List<TreatmentStat> treatments;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Top Treatments",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: HealthOverviewScreen.deepBlue,
            ),
          ),
          const SizedBox(height: 22),
          if (!hasData || treatments.isEmpty)
            const Text(
              "No treatment data has been added yet.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black45,
              ),
            )
          else
            ...treatments.map(
                  (t) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.name,
                        style: const TextStyle(
                          fontSize: 17,
                          color: HealthOverviewScreen.deepBlue,
                        ),
                      ),
                    ),
                    Text(
                      t.count.toString(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: HealthOverviewScreen.deepBlue,
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

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: HealthOverviewScreen.cardBlue,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: HealthOverviewScreen.borderBlue),
    boxShadow: [
      BoxShadow(
        color: Colors.lightBlue.withValues(alpha: .07),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ],
  );
}