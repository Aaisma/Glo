import 'package:flutter/material.dart';

import 'visit_log.dart';
import 'prescription.dart';
import 'treatment_tracker.dart';
import 'follow_up_reminder.dart';
import 'skin_tips.dart';

class DermaVisitScreen extends StatelessWidget {
  final String userId;

  const DermaVisitScreen({
    super.key,
    this.userId = "test-user-001",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// BACK BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: _circleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Derma Visit",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF24303F),
                            fontFamily: 'Serif',
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Manage your skin health journey\nwith ease ♡",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 22),

                        /// REMINDER CARD (static, no navigation)
                        _reminderCard(),

                        const SizedBox(height: 25),

                        const Text(
                          "My Derma Tools",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF24303F),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// TOOLS GRID
                        Expanded(
                          child: GridView(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 1.3,
                            ),
                            children: [
                              _toolCard(
                                context,
                                badge: getDynamicBadge("visits"),
                                icon: Icons.calendar_month_outlined,
                                title: "Log Visit",
                                subtitle: "Record doctor visits",
                                page: LogVisitScreen(userId: userId),
                              ),
                              _toolCard(
                                context,
                                badge: getDynamicBadge("prescriptions"),
                                icon: Icons.receipt_long_outlined,
                                title: "Prescription",
                                subtitle: "Store prescriptions",
                                page: PrescriptionScreen(userId: userId),
                              ),
                              _toolCard(
                                context,
                                badge: getDynamicBadge("treatments"),
                                icon: Icons.medication_outlined,
                                title: "Treatment Tracker",
                                subtitle: "Track treatment progress",
                                page: TreatmentTrackerScreen(userId: userId),
                              ),
                              _toolCard(
                                context,
                                badge: getDynamicBadge("reminders"),
                                icon: Icons.notifications_active_outlined,
                                title: "Follow-Up Reminder",
                                subtitle: "Never miss appointments",
                                page: FollowUpReminderScreen(userId: userId),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// SKIN TIP CARD
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SkinHealthTipsScreen(userId: userId),
                              ),
                            );
                          },
                          child: _skinTipCard(),
                        ),

                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper for dynamic badges (stubbed for now)
  String getDynamicBadge(String type) {
    // Replace with Firestore counts later
    switch (type) {
      case "visits":
        return "21";
      case "prescriptions":
        return "22";
      case "treatments":
        return "25";
      case "reminders":
        return "23";
      default:
        return "0";
    }
  }

  /// Circle Button
  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFFFF7DA4)),
        onPressed: onTap,
      ),
    );
  }

  /// Reminder Card
  Widget _reminderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFF4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFFFF7DA4),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Next Visit Reminder",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "10:30 AM",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Dr. Sarah Khan",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  "Skin & Hair Specialist",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: Color(0xFFFF7DA4),
          ),
        ],
      ),
    );
  }

  /// Tool Card
  Widget _toolCard(
      BuildContext context, {
        required String badge,
        required IconData icon,
        required String title,
        required String subtitle,
        required Widget page,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7DA4),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEFF4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        icon,
                        size: 34,
                        color: const Color(0xFFFF7DA4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Skin Tip Card
  Widget _skinTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFF4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFFFF7DA4),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Skin Health Tip",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Consistency is key! Follow your treatment plan and stay hydrated.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}