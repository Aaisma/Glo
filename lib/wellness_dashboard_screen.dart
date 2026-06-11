import 'package:flutter/material.dart';
import 'mood_calendar_screen.dart';

class WellnessDashboardScreen extends StatefulWidget {
  const WellnessDashboardScreen({super.key});

  @override
  State<WellnessDashboardScreen> createState() => _WellnessDashboardScreenState();
}

class _WellnessDashboardScreenState extends State<WellnessDashboardScreen> {
  /// 📊 Mock Growth Data mapped with plants inside pots to match UI mockup
  final List<Map<String, String>> _gardenPlants = [
    {'name': 'Amazing', 'flower': '🌹\n🪴'},
    {'name': 'Happy', 'flower': '🌻\n🪴'},
    {'name': 'Calm', 'flower': '💠\n🪴'},
    {'name': 'Energy', 'flower': '🌵\n🪴'},
    {'name': 'Sad', 'flower': '🪻\n🪴'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDFB), // Soft warm background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 1. Top Navigation Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black45),
                      onPressed: () {},
                    ),
                  ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('✨ ', style: TextStyle(fontSize: 14)),
                      Text(
                        'My Wellness',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF4081),
                        ),
                      ),
                      Text(' ✨', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Header Greetings
              const Row(
                children: [
                  Text(
                    'Good Morning, Shiny',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                  ),
                  SizedBox(width: 6),
                  Text('🌸', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 4),
                  Text('✨', style: TextStyle(fontSize: 14, color: Colors.amber)),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 14, color: Colors.black45),
              ),
              const SizedBox(height: 16),

              // 3. Pill-Shaped Log Mood Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF527B),
                    shadowColor: const Color(0xFFFF527B).withOpacity(0.2),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text(
                    'Log Your Mood',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Premium Mood Garden Shelf Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFF0F3), Color(0xFFFFE4E9)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Mood Garden',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // The Potted Plant Shelf Assembly
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: _gardenPlants.map((plant) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  plant['flower']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 26, height: 1.1),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  plant['name']!,
                                  style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500),
                                ),
                              ],
                            );
                          }).toList(),
                        ),

                        // 🪵 Wooden Stand Board
                        Container(
                          width: double.infinity,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4, bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCDA184),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),

                    const Center(
                      child: Column(
                        children: [
                          Text(
                            'Keep logging your moods',
                            style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('and watch your garden grow ', style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
                              Text('🌱', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. Symmetric Performance Metrics Dashboard Rows
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Current Streak', '7', 'days', '🔥')),
                  const SizedBox(width: 14),
                  Expanded(child: _buildMetricCard('Longest Streak', '21', 'days', '🏆')),
                ],
              ),
              const SizedBox(height: 16),

              // 6. Non-Scrolling Layout Core List (Using Expanded & Column to completely disable scroll physics)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildNavigationRow(
                        context,
                        Icons.calendar_month_outlined,
                        'Mood Calendar',
                        'Track your mood trends',
                        const Color(0xFFFF527B),
                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MoodCalendarScreen())),
                      ),
                    ),
                    Expanded(
                      child: _buildNavigationRow(context, Icons.local_florist_outlined, 'Mood Garden', 'See your emotional growth', Colors.orangeAccent, () {}),
                    ),
                    Expanded(
                      child: _buildNavigationRow(context, Icons.bar_chart_outlined, 'Insights & Analytics', 'Understand your mood patterns', Colors.indigoAccent, () {}),
                    ),
                    Expanded(
                      child: _buildNavigationRow(context, Icons.book_outlined, 'Mood Journal', 'Write your mood, thoughts & notes', Colors.teal, () {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String statusCount, String labelUnit, String emojiIcon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF5F5F5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(emojiIcon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                statusCount,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
              ),
              const SizedBox(width: 4),
              Text(labelUnit, style: const TextStyle(fontSize: 11, color: Colors.black38)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(BuildContext context, IconData icon, String title, String subtitle, Color colorTone, VoidCallback action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF8F8F8), width: 1),
      ),
      child: Center(
        child: ListTile(
          onTap: action,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorTone.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorTone, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.black38),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 11, color: Colors.black26),
        ),
      ),
    );
  }
}