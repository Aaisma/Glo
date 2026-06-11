import 'package:flutter/material.dart';
import 'mood_log_screen.dart';
import 'mood_calendar_screen.dart';

class WellnessDashboardScreen extends StatefulWidget {
  const WellnessDashboardScreen({super.key});

  @override
  State<WellnessDashboardScreen> createState() => _WellnessDashboardScreenState();
}

class _WellnessDashboardScreenState extends State<WellnessDashboardScreen> {
  // Updated: Changed 'Love' to 'Amazing'
  final Map<String, int> _moodLogCounts = {
    'Amazing': 4,
    'Happy': 3,
    'Calm': 2,
    'Energy': 1,
    'Sad': 5,
  };

  String _getGardenPlant(String moodType, int logCount) {
    if (logCount == 0) return '🌱';
    if (logCount <= 2) return '🪴';

    switch (moodType) {
      case 'Amazing': return '🌹';
      case 'Happy': return '🌻';
      case 'Calm': return '💠';
      case 'Energy': return '🌵';
      case 'Sad': return '🪻';
      default: return '🌸';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      body: SafeArea(
        // Enforces single-screen mode (No scrolling, no overflow!)
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 1. App Header Layout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black54),
                    onPressed: () {},
                  ),
                  const Text(
                    'My Wellness 🌷',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2A4A)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined, size: 22, color: Colors.black54),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 6), // Tightened spacing

              // 2. Greeting
              const Text(
                'Good Morning, Shiny 🌸',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1D2A4A)),
              ),
              const SizedBox(height: 2),
              const Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12), // Tightened spacing

              // 3. Pink Action Banner
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MoodLogScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B8B), Color(0xFFFF8E7A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.white, size: 36),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Log Your Mood', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('Track how you\'re feeling today', style: TextStyle(fontSize: 11, color: Colors.white70)),
                        ],
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12), // Tightened spacing

              // 4. My Mood Garden Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('🌸 ', style: TextStyle(fontSize: 14)),
                            Text('My Mood Garden', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1D2A4A))),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: const Text('View Garden >', style: TextStyle(fontSize: 11, color: Colors.redAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _moodLogCounts.entries.map((entry) {
                        return Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 18.0),
                                  child: Text(_getGardenPlant(entry.key, entry.value), style: const TextStyle(fontSize: 28)),
                                ),
                                const Text('🪵', style: TextStyle(fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(entry.key, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Nurture your emotions and watch your garden grow 🌱',
                      style: TextStyle(fontSize: 10, color: Colors.black38, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12), // Tightened spacing

              // 5. Streaks Row
              Row(
                children: [
                  Expanded(child: _buildStreakCard('Current Streak', '9', 'days', '🔥', const Color(0xFFFFF2E6))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStreakCard('Longest Streak', '24', 'days', '🏆', const Color(0xFFEBF3FF))),
                ],
              ),
              const SizedBox(height: 12), // Tightened spacing

              // 6. EXACT ORIGINAL Vertical List Menu (Optimized to occupy remaining space perfectly)
              Expanded(
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(), // Disables list scrolling container entirely
                  padding: EdgeInsets.zero,
                  children: [
                    _buildListTile(
                      context,
                      Icons.calendar_month_outlined,
                      'Mood Calendar',
                      'Track your mood trends',
                      Colors.pinkAccent,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MoodCalendarScreen())),
                    ),
                    _buildListTile(context, Icons.local_florist_outlined, 'Mood Garden', 'See your emotional growth', Colors.orangeAccent, () {}),
                    _buildListTile(context, Icons.bar_chart_outlined, 'Insights & Analytics', 'Understand your mood patterns', Colors.deepPurpleAccent, () {}),
                    _buildListTile(context, Icons.assignment_outlined, 'Mood Details', 'View your mood history & notes', Colors.green, () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(String title, String count, String unit, String icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, color: Colors.black54)),
              Text(count, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1D2A4A))),
              Text(unit, style: const TextStyle(fontSize: 10, color: Colors.black38)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, String subtitle, Color iconColor, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Clean spacing between tiles
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        dense: true, // Decreases vertical density slightly to fit single screen effortlessly
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(icon, color: iconColor, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1D2A4A))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black38)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black26),
        onTap: onTap,
      ),
    );
  }
}