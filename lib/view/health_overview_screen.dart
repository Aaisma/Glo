import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/health_overview_model.dart';
import '../viewmodel/admin_health_overview_viewmodel.dart';

class HealthOverviewScreen extends StatelessWidget {
  const HealthOverviewScreen({super.key});

  static const Color primaryBlue = Color(0xFF9BD8FA);
  static const Color deepBlue = Color(0xFF21475E);
  static const Color softBlue = Color(0xFFEFF9FF);
  static const Color cardBlue = Color(0xFFFAFDFF);
  static const Color bg = Color(0xFFF4FBFF);
  static const Color borderBlue = Color(0xFFDDF2FF);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AdminHealthOverviewViewModel>(context);
    final overview = vm.overview ?? HealthOverviewData.empty();
    final hasData = vm.overview != null;

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
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
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

  Decoration? _cardDecoration() {
    return null;
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

  Decoration? _cardDecoration() {
    return null;
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

  Decoration? _cardDecoration() {
    return null;
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

  Decoration? _cardDecoration() {
    return null;
  }
}
