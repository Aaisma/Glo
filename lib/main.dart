import 'package:flutter/material.dart';

class JournalActivityScreen extends StatefulWidget {
  const JournalActivityScreen({super.key});

  @override
  State<JournalActivityScreen> createState() =>
      _JournalActivityScreenState();
}

class _JournalActivityScreenState
    extends State<JournalActivityScreen> {

  static const Color primaryPink = Color(0xFFFF3E63);

  int selectedMood = -1;

  final TextEditingController journalController =
  TextEditingController();

  @override
  void dispose() {
    journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [

              /// HEADER
              Row(
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),

                  const SizedBox(width: 12),

                  const Text(
                    "Today's Journal",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  Stack(
                    children: [
                      const Icon(Icons.notifications_none),
                      Positioned(
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: primaryPink,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "May 24, 2026",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// FEELING CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(22),
                ),
                child: Column(
                  children: [

                    Row(
                      children: [

                        const Expanded(
                          child: Text(
                            "How are you feeling today?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),

                        /// FLOWER IMAGE
                        Image.asset(
                          "assets/images/flower.png",
                          height: 80,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        moodCard(
                          0,
                          Icons.psychology_outlined,
                          "Stressed",
                        ),
                        moodCard(
                          1,
                          Icons.chat_bubble_outline,
                          "Motivated",
                        ),
                        moodCard(
                          2,
                          Icons.sentiment_neutral,
                          "Indifferent",
                        ),
                        moodCard(
                          3,
                          Icons.water_drop_outlined,
                          "Calm",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// JOURNAL CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: journalController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText:
                    "Write how you feel today...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget moodCard(
      int index,
      IconData icon,
      String title,
      ) {
    bool isSelected =
        selectedMood == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMood = index;
          });
        },
        child: Container(
          margin:
          const EdgeInsets.symmetric(
              horizontal: 4),
          padding:
          const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryPink.withOpacity(.15)
                : Colors.white,
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? primaryPink
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: primaryPink,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}