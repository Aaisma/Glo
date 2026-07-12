import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/wellness_viewmodel.dart';

import '../../viewmodel/user_viewmodel.dart';

class WellnessDashboardScreen extends StatefulWidget {
  const WellnessDashboardScreen({super.key});

  @override
  State<WellnessDashboardScreen> createState() => _WellnessDashboardScreenState();
}

class _WellnessDashboardScreenState extends State<WellnessDashboardScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserViewModel>().user;
      if (user != null) {
        context.read<WellnessViewModel>().initUserSync(user.id);
      }
    });
  }

  /// Helper to render the correct plant asset stage dynamically based on entry count from MVVM
  String _getGardenPlant(String moodKey, int count) {
    if (count == 0) return '🌱\n🪴'; // Seedling state if zero logs exist
    switch (moodKey) {
      case 'Amazing': return '🌹\n🪴';
      case 'Happy': return '🌻\n🪴';
      case 'Calm': return '💠\n🪴';
      case 'Energy': return '🌵\n🪴';
      case 'Sad': return '🪻\n🪴';
      default: return '🌱\n🪴';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Consumer<WellnessViewModel>(
          builder: (context, viewModel, child) {

            // Fix & Optimization: Safely initialize map and fallback if moodHistory is null or empty
            final Map<String, int> liveMoodCounts = {
              'Amazing': 0,
              'Happy': 0,
              'Calm': 0,
              'Energy': 0,
              'Sad': 0,
            };

            // Safely iterate through the history once (O(N) instead of O(5N)) to avoid breakdown errors
            for (var mood in viewModel.moodHistory) {
              if (liveMoodCounts.containsKey(mood.moodType)) {
                liveMoodCounts[mood.moodType] = (liveMoodCounts[mood.moodType] ?? 0) + 1;
              }
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Bar Navigation Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
                          onPressed: () {
                            if (Navigator.canPop(context)) Navigator.pop(context);
                          },
                        ),
                      ),
                      const Text(
                        'My Wellness',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF263238),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Greeting Header Text Elements
                  const Text(
                    'Good Morning, Shiny 🌸',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'How are you feeling today?',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // 3. Main Action Mood Logging Button (Premium Capsule Setup)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/mood_log');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF3E63), Color(0xFFFF7A85)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3E63).withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, color: Color(0xFFFF3E63), size: 18),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Log Your Mood',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Text(
                                    "Track how you're feeling today",
                                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Premium Potted Mood Garden Card (Dynamically Driven)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text('🌷 ', style: TextStyle(fontSize: 16)),
                                Text(
                                  'Your Mood Garden',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/mood_garden');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE4E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      'View Garden ',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF3E63)),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFFFF3E63)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Dynamic Garden Shelf Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: liveMoodCounts.entries.map((entry) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getGardenPlant(entry.key, entry.value),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 26, height: 1.1),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500),
                                ),
                              ],
                            );
                          }).toList(),
                        ),

                        // 🪵 Wooden Planter Board shelf
                        Container(
                          width: double.infinity,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4, bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCDA184),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        const Center(
                          child: Text(
                            'Keep logging your moods and watch your garden grow! 🌱',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Symmetric Achievement Streak Layout Cards (Dynamic Bindings)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                            'Current Streak',
                            '${viewModel.currentStreak}',
                            'days', '🔥', Colors.orange[50]!
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildMetricCard(
                            'Longest Streak',
                            '${viewModel.longestStreak}',
                            'days', '🏆', Colors.blue[50]!
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 6. Navigation Features
                  _buildNavigationRow(
                    context,
                    Icons.calendar_month_outlined,
                    'Mood Calendar',
                    'Track your mood trends',
                    const Color(0xFFFF527B),
                        () => Navigator.pushNamed(context, '/mood_calendar'),
                  ),
                  _buildNavigationRow(
                    context,
                    Icons.bar_chart_outlined,
                    'Mood Summary',
                    'Understand your mood patterns',
                    Colors.indigoAccent,
                        () => Navigator.pushNamed(context, '/mood_summary'),
                  ),

                  const SizedBox(height: 20),

                  // 7. Beautiful Inspirational Quote Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE7FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Text('“', style: TextStyle(fontSize: 24, color: Colors.purple, fontWeight: FontWeight.bold, height: 0.6)),
                        Text(
                          'You’re allowed to be both\na masterpiece and a work in progress.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Color(0xFF5E35B1), fontWeight: FontWeight.w600, height: 1.4),
                        ),
                        SizedBox(height: 6),
                        Text('💜', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String statusCount, String labelUnit, String emojiIcon, Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(emojiIcon, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Text(
                statusCount,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
              ),
              const SizedBox(width: 4),
              Text(labelUnit, style: const TextStyle(fontSize: 11, color: Colors.black45)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(BuildContext context, IconData icon, String title, String subtitle, Color colorTone, VoidCallback action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        onTap: action,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorTone.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorTone, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.black45),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black38),
      ),
    );
  }
}