import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodHomeScreen extends StatefulWidget {
  const MoodHomeScreen({super.key});

  @override
  State<MoodHomeScreen> createState() => _MoodHomeScreenState();
}

class _MoodHomeScreenState extends State<MoodHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Mood Tracker",
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text("Good Morning, Shiny 🌸",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text("How are you feeling today?",
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 20),

              // Log Mood Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3E63), Color(0xFFFF7A85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.pink.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.add, color: Colors.pink),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Log Your Mood",
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          Text("Track how you're feeling today",
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ]),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Mood Garden Shelf with quote + button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown[200],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _flowerItem("assets/images/rose.png", "Love"),
                        _flowerItem("assets/images/sunflower.png", "Happy"),
                        _flowerItem("assets/images/blue_flower.png", "Calm"),
                        _flowerItem("assets/images/cactus.png", "Uneasy"),
                        _flowerItem("assets/images/purple_flower.png", "Sad"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text("Keep logging your moods and watch your garden grow 🌱",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                      ),
                      onPressed: () {
                        // TODO: Add your dynamic action here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Mood entry button pressed!")),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text("Add Mood Entry",
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Smaller Streak Cards with Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _smallStatCard("Current Streak", "7", "Days",
                      Colors.orange[100]!, Icons.local_fire_department),
                  _smallStatCard("Longest Streak", "21", "Days",
                      Colors.blue[100]!, Icons.emoji_events),
                ],
              ),
              const SizedBox(height: 24),

              // Menu Section with navigation
              _menuTile(context, "Mood Calendar", "Track your mood and emotions",
                  Icons.calendar_today, const MoodCalendarScreen()),
              _menuTile(context, "Mood Garden",
                  "See your emotions bloom into a beautiful garden",
                  Icons.local_florist, const MoodGardenScreen()),
              _menuTile(context, "Insights & Analytics",
                  "Understand your emotional patterns", Icons.bar_chart,
                  const InsightsScreen()),
              _menuTile(context, "Mood Data", "View and export detailed mood data",
                  Icons.notes, const MoodDataScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flowerItem(String path, String mood) {
    return Column(
      children: [
        Image.asset(path, width: 55, height: 55),
        const SizedBox(height: 6),
        Text(mood,
            style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // Smaller streak card
  Widget _smallStatCard(
      String title, String value, String subtitle, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12), // smaller padding
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black54, size: 22), // smaller icon
            const SizedBox(height: 6),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(BuildContext context, String title, String subtitle,
      IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.pink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens
// Placeholder screens

class MoodCalendarScreen extends StatelessWidget {
  const MoodCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Calendar"),
      ),
      body: const Center(
        child: Text("Mood Calendar Screen"),
      ),
    );
  }
}

class MoodGardenScreen extends StatelessWidget {
  const MoodGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Garden"),
      ),
      body: const Center(
        child: Text("Mood Garden Screen"),
      ),
    );
  }
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights & Analytics"),
      ),
      body: const Center(
        child: Text("Insights & Analytics Screen"),
      ),
    );
  }
}

class MoodDataScreen extends StatelessWidget {
  const MoodDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Data"),
      ),
      body: const Center(
        child: Text("Mood Data Screen"),
      ),
    );
  }
}