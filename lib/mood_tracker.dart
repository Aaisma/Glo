 import 'package:flutter/material.dart';

class MoodTracker extends StatelessWidget {
  const MoodTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FA),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              /// TOP SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  Row(
                    children: [

                      /// BACK BUTTON
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },

                        child: Container(
                          padding: const EdgeInsets.all(10),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: const [

                          Text(
                            "Good Evening, Shiny 💖",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            "How are you feeling today?",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Row(
                    children: [

                      topIcon(Icons.calendar_today_outlined),

                      const SizedBox(width: 10),

                      topIcon(Icons.notifications_none),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              /// MOOD CARDS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  moodCard("Amazing", "😍", Colors.purple.shade100),

                  moodCard("Happy", "😊", Colors.pink.shade100),

                  moodCard("Calm", "😌", Colors.deepPurple.shade100),

                  selectedMoodCard(),

                  moodCard("Sad", "🥺", Colors.indigo.shade100),

                  moodCard("Angry", "😡", Colors.red.shade100),
                ],
              ),

              const SizedBox(height: 30),

              /// TRACK SYMPTOMS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  const Text(
                    "Track your symptoms",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  Text(
                    "+ Add custom",
                    style: TextStyle(
                      color: Colors.pink.shade300,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 10,
                runSpacing: 10,

                children: [

                  symptomChip("⚡ Cramps"),
                  symptomChip("💨 Bloating"),
                  symptomChip("🤕 Headache"),
                  symptomChip("🌸 Acne"),
                  symptomChip("😴 Low Energy"),
                  symptomChip("😰 Stress"),
                  symptomChip("💗 Anxiety"),
                  symptomChip("🩹 Back Pain"),
                  symptomChip("✨ Tender Breasts"),
                  symptomChip("+ More"),
                ],
              ),

              const SizedBox(height: 28),

              /// GLO INSIGHTS
              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),

                  gradient: LinearGradient(
                    colors: [
                      Colors.pink.shade100,
                      Colors.white,
                    ],
                  ),
                ),

                child: Row(
                  children: [

                    Container(
                      width: 65,
                      height: 65,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        gradient: LinearGradient(
                          colors: [
                            Colors.pink.shade300,
                            Colors.pink.shade100,
                          ],
                        ),
                      ),

                      child: const Center(
                        child: Text(
                          "Glo",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          const Text(
                            "Glo Insights ✨",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "You've felt tired for 3 days in a row.\nThis may be related to your sleep\nor cycle phase.",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// NOTE + WELLNESS
              Row(
                children: [

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          const Text(
                            "Talk about your day",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Write your thoughts, feelings\nor anything useful...",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(30),
                            ),

                            child: Text(
                              "+ Add Note",
                              style: TextStyle(
                                color: Colors.pink.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          const Text(
                            "Today's Wellness Check ✨",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 15),

                          wellnessTile("🛌 Sleep", "6h 22m"),

                          wellnessTile("💧 Water", "2.2L"),

                          wellnessTile("🔥 Stress", "Moderate"),

                          wellnessTile("⚡ Energy", "Low"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// GRAPH TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  const Text(
                    "Your mood this week",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  Text(
                    "View insights →",
                    style: TextStyle(
                      color: Colors.pink.shade300,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// GRAPH
              Container(
                height: 220,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),

                child: Column(
                  children: [

                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [

                          moodPoint(90, "😍"),
                          moodPoint(45, "🙂"),
                          moodPoint(100, "🥰"),
                          moodPoint(35, "😔"),
                          moodPoint(70, "😊"),
                          moodPoint(110, "😍"),
                          moodPoint(55, "😌"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: const [

                        Text("Sun\n12",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11)),

                        Text("Mon\n13",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11)),

                        Text("Tue\n14",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11)),

                        Text(
                          "Wed\n15",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text("Thu\n16",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11)),

                        Text("Fri\n17",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11)),

                        Text("Sat\n18",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11)),
                      ],
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

  static Widget moodCard(
      String title,
      String emoji,
      Color color,
      ) {
    return Container(
      width: 52,
      height: 78,

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  static Widget selectedMoodCard() {
    return Container(
      width: 60,
      height: 92,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        border: Border.all(
          color: Colors.pink.shade200,
          width: 2,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade100,
            blurRadius: 12,
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: const [

          Text(
            "🥱",
            style: TextStyle(fontSize: 22),
          ),

          SizedBox(height: 8),

          Text(
            "Tired",
            style: TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  static Widget symptomChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 12,
        ),
      ),
    );
  }

  static Widget wellnessTile(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Text(title),

          Text(
            value,
            style: TextStyle(
              color: Colors.pink.shade300,
            ),
          ),
        ],
      ),
    );
  }

  static Widget topIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Icon(
        icon,
        size: 18,
        color: Colors.pink.shade300,
      ),
    );
  }

  static Widget moodPoint(
      double height,
      String emoji,
      ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,

      children: [

        Text(
          emoji,
          style: const TextStyle(fontSize: 18),
        ),

        const SizedBox(height: 6),

        Container(
          width: 3,
          height: height,

          decoration: BoxDecoration(
            color: Colors.pink.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        Container(
          width: 14,
          height: 14,

          decoration: BoxDecoration(
            color: Colors.pink.shade300,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}