import 'package:flutter/material.dart';

void main() {
  runApp(const Glo());
}

// Root widget
class Glo extends StatelessWidget {
  const Glo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glo',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const SkinHealthTipsScreen(),
    );
  }
}

// Skin Health Tips Screen
class SkinHealthTipsScreen extends StatelessWidget {
  const SkinHealthTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Skin Health Tips"),
        backgroundColor: Colors.pink,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Text(
                "Featured Tip",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Card(
                color: Colors.white70,
                child: ListTile(
                  leading: Image.asset("assets/images/flower.png", width: 50),
                  title: const Text("Always Use Sunscreen"),
                  subtitle: const Text(
                    "Protect your skin by applying sunscreen daily, even on cloudy days. Choose SPF 30 or higher.",
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "More Tips",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Stay Hydrated
              Card(
                color: Colors.white70,
                child: ListTile(
                  leading: Image.asset("assets/images/notes.png", width: 40),
                  title: const Text("Stay Hydrated"),
                  subtitle: const Text("Drink plenty of water to keep your skin hydrated and healthy."),
                ),
              ),

              // Gentle Cleansing
              Card(
                color: Colors.white70,
                child: ListTile(
                  leading: Image.asset("assets/images/creamtube.png", width: 40),
                  title: const Text("Gentle Cleansing"),
                  subtitle: const Text("Use a mild cleanser to avoid irritating your skin."),
                ),
              ),

              // Healthy Diet
              Card(
                color: Colors.white70,
                child: ListTile(
                  leading: Image.asset("assets/images/labresult.png", width: 40),
                  title: const Text("Healthy Diet"),
                  subtitle: const Text("Eat more fruits and vegetables for clear, radiant skin."),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CommunityScreen()),
                    );
                  },
                  child: const Text("More Tips & Community"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder Community Screen
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Community"), backgroundColor: Colors.pink),
      body: const Center(
        child: Text("Community discussions and more tips here!", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
