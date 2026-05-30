import 'package:flutter/material.dart';

void main() {
  runApp(const AcneTrackerApp());
}

class AcneTrackerApp extends StatelessWidget {
  const AcneTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acne Tracker',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFE4E1), // baby pink
        primaryColor: Colors.pinkAccent,
      ),
      home: const AcneTrackerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AcneTrackerPage extends StatelessWidget {
  const AcneTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acne Tracker'),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt),
                label: const Text('Upload a Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent.shade100,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Acne Types
            const SectionTitle(title: 'Acne Types', subtitle: 'Identify Your Breakouts'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                acneCard('Whiteheads'),
                acneCard('Blackheads'),
                acneCard('Papules'),
                acneCard('Pustules'),
                acneCard('Nodules'),
                acneCard('Cystic Acne'),
              ],
            ),
            const SizedBox(height: 20),

            // Acne Causes
            const SectionTitle(title: 'Acne Causes', subtitle: 'Learn About Triggers'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                causeCard('Hormones', Icons.female),
                causeCard('Diet & Food', Icons.fastfood),
                causeCard('Stress', Icons.sentiment_dissatisfied),
                causeCard('Skincare Products', Icons.spa),
              ],
            ),
            const SizedBox(height: 20),

            // Progress Chart (placeholder)
            const SectionTitle(title: 'Progress Chart', subtitle: 'Breakout Severity Over Time'),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('📈 Chart Placeholder')),
            ),
            const SizedBox(height: 20),

            // Daily Care Checklist
            const SectionTitle(title: 'Daily Care Checklist', subtitle: 'Track Your Routine'),
            checklistItem('Washed Face Twice'),
            checklistItem('Applied Moisturizer'),
            checklistItem('Avoided Touching Face'),
            checklistItem('Stayed Hydrated'),
            const SizedBox(height: 20),

            // Product Tracker
            const SectionTitle(title: 'Product Tracker', subtitle: 'Skincare Products Used'),
            productItem('Salicylic Acid Cleanser', 4),
            productItem('Niacinamide Serum', 3),
            const SizedBox(height: 20),

            // Daily Journal
            const SectionTitle(title: 'Daily Journal', subtitle: 'Write About Your Day'),
            TextField(
              decoration: InputDecoration(
                hintText: "Today's Entry...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            const Text(
              'April 22, 2022 - "Feeling frustrated today. Skin is breaking out a lot."',
              style: TextStyle(color: Colors.black54),
            ),
            const Text(
              'April 20, 2022 - "Tried a new cleanser. Hoping it helps!"',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Tips & Advice
            const SectionTitle(title: 'Tips & Advice', subtitle: 'Daily Skincare Guidance'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Tip of the Day: Avoid touching your face to reduce acne flare-ups.',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget acneCard(String title) => Container(
    width: 100,
    height: 80,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(child: Text(title)),
  );

  Widget causeCard(String title, IconData icon) => Container(
    width: 150,
    height: 80,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.pinkAccent),
        const SizedBox(height: 5),
        Text(title),
      ],
    ),
  );

  Widget checklistItem(String text) => Row(
    children: [
      Checkbox(value: true, onChanged: (val) {}),
      Text(text),
    ],
  );

  Widget productItem(String name, int rating) => ListTile(
    title: Text(name),
    subtitle: Row(
      children: List.generate(
        5,
            (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.pinkAccent,
          size: 20,
        ),
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const SectionTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        Text(subtitle, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 10),
      ],
    );
  }
}
