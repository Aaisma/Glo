import 'package:flutter/material.dart';

class AcneTrackerPage extends StatelessWidget {
  const AcneTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Acne Tracker"),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        // 👇 Background image setup
        // Make sure you have assets/images/background.png
        // and listed it in pubspec.yaml under flutter: assets:
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"), // 👈 background
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current Acne Status
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: const [
                      Text(
                        "Current Acne Status",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("Severity: Moderate"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Acne Types Gallery
              const Text(
                "Acne Types",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  acneImageCard("Whiteheads", "assets/images/whiteheads.png"),
                  acneImageCard("Blackheads", "assets/images/blackheads.png"),
                  acneImageCard("Papules", "assets/images/papules.png"),
                  acneImageCard("Pustules", "assets/images/pustules.png"),
                  acneImageCard("Nodules", "assets/images/nodules.png"),
                  acneImageCard("Cystic Acne", "assets/images/cystic.png"),
                ],
              ),
              const SizedBox(height: 20),

              // Journal Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Daily Journal",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Write your notes...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "May 31, 2026 - 'Skin feels better today after using moisturizer.'",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const Text(
                        "May 30, 2026 - 'Breakouts increased after stress.'",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Motivation Section
              Card(
                color: Colors.pink[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "✨ Stay confident, healing takes time! ✨",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 👇 Helper widget for acne images
  static Widget acneImageCard(String title, String assetPath) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(assetPath), // 👈 your acne image file
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.black54,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
