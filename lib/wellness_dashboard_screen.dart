import 'package:flutter/material.dart';
import 'mood_log_screen.dart';
import 'mood_calendar_screen.dart';

class WellnessDashboardScreen extends StatefulWidget {
  const WellnessDashboardScreen({super.key});

  @override
  State<WellnessDashboardScreen> createState() => _WellnessDashboardScreenState();
}

class _WellnessDashboardScreenState extends State<WellnessDashboardScreen> {
  /// 📊 MOOD DATABASE & LOG COUNTER
  /// Adjust these numbers to test the organic plant growth stages!
  /// 0 = Fresh sprout, 1 to 3 = Mid-growth pot, 4+ = Fully matured flower
  final Map<String, int> _moodLogCounts = {
    'Amazing': 5, // Fully grown rose 🌹
    'Happy': 3,   // Mid-growth potted plant 🪴
    'Calm': 0,    // Fresh new sprout 🌱
    'Energy': 4,  // Fully grown cactus 🌵
    'Sad': 6,     // Fully grown drooping flower 🪻
  };

  /// 🪴 DYNAMIC GROWTH ENGINE
  /// Generates the plant stage asset seamlessly based on actual usage logs
  String _getGardenPlant(String moodType, int logCount) {
    if (logCount == 0) {
      return '🌱'; // Stage 1: Brand new seedling sprout
    } else if (logCount > 0 && logCount <= 3) {
      return '🪴'; // Stage 2: Growing juvenile plant
    }

    // Stage 3: Fully Matured Flower Unique to Each Emotion!
    switch (moodType) {
      case 'Amazing': return '🌹';
      case 'Happy': return '🌻';
      case 'Calm': return '💠';
      case 'Energy': return '🌵';
      case 'Sad': return '🪻'; // Drooping purple hyacinth flower
      default: return '🌸';
    }
  }

  /// 📏 VISUAL SCALING ENGINE
  /// Scales the plant size up dynamically as logs accumulate
  double _getPlantSize(int logCount) {
    if (logCount == 0) return 20.0;
    if (logCount <= 3) return 24.0;
    return 32.0; // Fully matured plant sizing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
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
              const SizedBox(height: 4),

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
              const SizedBox(height: 10),

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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B8B), Color(0xFFFF8E7A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.white, size: 34),
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
              const SizedBox(height: 10),

              // 4. Mood Garden Card Widget with Wood Shelf Display Layer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                            Text('🪴 ', style: TextStyle(fontSize: 14)),
                            Text('Mood Garden', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1D2A4A))),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: const Text('View Garden >', style: TextStyle(fontSize: 11, color: Colors.redAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // The Interactive Plant & Shelf Column Grid Layout
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: Alignment.bottom,
                          children: _moodLogCounts.entries.map((entry) {
                            final int logCount = entry.value;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  _getGardenPlant(entry.key, logCount),
                                  style: TextStyle(fontSize: _getPlantSize(logCount)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w500),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        // 🪵 The Styled Linear Wooden Stand Element
                        Container(
                          width: double.infinity,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4, bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD7CCC8), // Cozy wood tan color
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Nurture your emotions and watch your garden grow 🌱',
                      style: TextStyle(fontSize: 10, color: Colors.black38, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 5. Streaks Panel Row
              Row(
                children: [
                  Expanded(child: _buildStreakCard('Current Streak', '9', 'days', '🔥', const Color(0xFFFFF2E6))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStreakCard('Longest Streak', '24', 'days', '🏆', const Color(0xFFEBF3FF))),
                ],
              ),
              const SizedBox(height: 10),

              // 6. Navigation List Tiles Menu (Fixed height block prevents overflow scrolling)
              Expanded(
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
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
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        leading: Icon(icon, color: iconColor, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1D2A4A))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black38)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black26),
        onTap: onTap,
      ),
    );
  }
}