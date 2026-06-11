import 'package:flutter/material.dart';
import 'mood_log_screen.dart';
import 'mood_calendar_screen.dart';

class WellnessDashboardScreen extends StatefulWidget {
  const WellnessDashboardScreen({super.key});

  @override
  State<WellnessDashboardScreen> createState() => _WellnessDashboardScreenState();
}

class _WellnessDashboardScreenState extends State<WellnessDashboardScreen> {
  /// 📊 CURRENT MOOD DATABASE (Simulating how many times the user logged each mood)
  /// Change these numbers to test the growth stages!
  /// 0 = Brand new sprout, 1-3 = Growing plant, 4+ = Fully matured beautiful flower.
  final Map<String, int> _moodLogCounts = {
    'Amazing': 5, // Fully grown rose!
    'Happy': 3,   // Mid-growth potted plant
    'Calm': 0,    // Fresh new sprout
    'Energy': 1,  // Mid-growth potted plant
    'Sad': 4,     // Fully grown hyacinth!
  };

  /// 🪴 DYNAMIC GROWTH ENGINE
  /// Determines what emoji to show based on how many times the user logged it.
  String _getGardenPlant(String moodType, int logCount) {
    if (logCount == 0) {
      return '🌱'; // Stage 1: Brand new sprout for everyone
    } else if (logCount > 0 && logCount <= 3) {
      return '🪴'; // Stage 2: Growing in a small pot
    }

    // Stage 3: Fully Matured Flower Unique to Each Emotion!
    switch (moodType) {
      case 'Amazing': return '🌹';
      case 'Happy': return '🌻';
      case 'Calm': return '💠';
      case 'Energy': return '🌵';
      case 'Sad': return '🪻';
      default: return '🌸';
    }
  }

  /// 📏 DYNAMIC SIZE ENGINE
  /// Makes the plant physically bigger on screen as the user logs it more!
  double _getPlantSize(int logCount) {
    if (logCount == 0) return 20.0; // Small sprout
    if (logCount <= 3) return 26.0; // Medium pot
    return 34.0;                    // Fully grown massive flower!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      body: SafeArea(
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
              const SizedBox(height: 6),

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
              const SizedBox(height: 12),

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
              const SizedBox(height: 12),

              // 4. Real Organic Mood Garden Patch Section (Staggered Layout)
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
                            Text('🏡 ', style: TextStyle(fontSize: 14)),
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

                    // 🌲 THE LIVING GARDEN FLOOR
                    Container(
                      height: 115,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)], // Soft grass field green
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          // 🌸 Amazing Flower (Back Left Position)
                          Positioned(
                            top: 10,
                            left: 30,
                            child: _buildGardenSprout('Amazing'),
                          ),

                          // 💠 Calm Flower (Back Right Position)
                          Positioned(
                            top: 12,
                            right: 35,
                            child: _buildGardenSprout('Calm'),
                          ),

                          // 🌵 Energy Cactus (Dead Center Position)
                          Positioned(
                            top: 32,
                            left: MediaQuery.of(context).size.width * 0.38,
                            child: _buildGardenSprout('Energy'),
                          ),

                          // 🌻 Happy Sunflower (Front Left Position)
                          Positioned(
                            bottom: 6,
                            left: 65,
                            child: _buildGardenSprout('Happy'),
                          ),

                          // 🪻 Sad Flower (Front Right Position)
                          Positioned(
                            bottom: 6,
                            right: 65,
                            child: _buildGardenSprout('Sad'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Nurture your emotions and watch your garden grow 🌱',
                      style: TextStyle(fontSize: 10, color: Colors.black38, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 5. Streaks Row
              Row(
                children: [
                  Expanded(child: _buildStreakCard('Current Streak', '9', 'days', '🔥', const Color(0xFFFFF2E6))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStreakCard('Longest Streak', '24', 'days', '🏆', const Color(0xFFEBF3FF))),
                ],
              ),
              const SizedBox(height: 12),

              // 6. Navigation List Menu (Strictly unscrollable to protect layout sizing)
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

  /// 🌸 INDIVIDUAL SEEDLING INTERACTIVE BUILDER
  Widget _buildGardenSprout(String moodKey) {
    final int logCount = _moodLogCounts[moodKey] ?? 0;
    final String plantEmoji = _getGardenPlant(moodKey, logCount);
    final double plantSize = _getPlantSize(logCount);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The Plant structure itself
        AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            plantEmoji,
            style: TextStyle(fontSize: plantSize),
          ),
        ),
        const SizedBox(height: 2),
        // Mood Label Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            moodKey,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1D2A4A)),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, String subtitle, Color iconColor, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        dense: true,
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