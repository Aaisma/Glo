import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JournalActivityScreen extends StatefulWidget {
  const JournalActivityScreen({super.key});

  @override
  State<JournalActivityScreen> createState() =>
      _JournalActivityScreenState();
}

class _JournalActivityScreenState
    extends State<JournalActivityScreen> {
  static const Color primaryPink =
  Color(0xFFFF3E63);

  final TextEditingController journalController =
  TextEditingController();

  String selectedMood = "";

  int streak = 3;

  final List<Map<String, dynamic>> moods = [
    {
      "title": "Stressed",
      "icon": Icons.psychology_outlined,
    },
    {
      "title": "Motivated",
      "icon": Icons.chat_bubble_outline,
    },
    {
      "title": "Indifferent",
      "icon": Icons.sentiment_neutral,
    },
    {
      "title": "Calm",
      "icon": Icons.water_drop_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    String date =
    DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              /// TOP BAR
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                    Colors.grey.shade100,
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Text(
                    "Today's Journal",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  Stack(
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        size: 28,
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration:
                          const BoxDecoration(
                            color: primaryPink,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),

              const SizedBox(height: 10),

              Text(
                date,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

              /// FEELINGS CARD
              buildFeelingsCard(),

              const SizedBox(height: 20),

              /// JOURNAL CARD
              buildJournalCard(),

              const SizedBox(height: 20),

              /// VOICE CARD
              buildVoiceCard(),

              const SizedBox(height: 20),

              /// ACTIVITY SECTION
              buildActivitySection(),

              const SizedBox(height: 20),

              /// STREAK
              buildStreakCard(),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content:
                        Text("Journal Saved"),
                      ),
                    );
                  },
                  child: const Text(
                    "Save Journal",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFeelingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          const Text(
            "How are you feeling today?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: moods.map((mood) {
              bool isSelected =
                  selectedMood == mood["title"];

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood =
                      mood["title"];
                    });
                  },
                  child: Container(
                    margin:
                    const EdgeInsets.symmetric(
                        horizontal: 4),
                    padding:
                    const EdgeInsets.all(10),
                    decoration:
                    BoxDecoration(
                      color: isSelected
                          ? primaryPink
                          .withOpacity(0.15)
                          : Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                          15),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          mood["icon"],
                          color: primaryPink,
                        ),
                        const SizedBox(
                            height: 6),
                        Text(
                          mood["title"],
                          textAlign:
                          TextAlign.center,
                          style:
                          const TextStyle(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget buildJournalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Column(
        children: [

          Row(
            children: const [
              Icon(
                Icons.edit_note,
                color: primaryPink,
              ),
              SizedBox(width: 10),
              Text(
                "Write your journal",
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              )
            ],
          ),

          TextField(
            controller: journalController,
            maxLines: 5,
            decoration:
            const InputDecoration(
              hintText:
              "Write how you feel today...",
              border: InputBorder.none,
            ),
          )
        ],
      ),
    );
  }

  Widget buildVoiceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        primaryPink.withOpacity(0.08),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        children: [

          const CircleAvatar(
            backgroundColor:
            Color(0x22FF3E63),
            child: Icon(
              Icons.mic,
              color: primaryPink,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Text(
              "Voice Journal",
              style: TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () {},
            child:
            const Text("Record"),
          )
        ],
      ),
    );
  }

  Widget buildActivitySection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        const Text(
          "What did you do today?",
          style: TextStyle(
            fontSize: 18,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: activityCard(
                Icons.directions_run,
                "Log Activity",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: activityCard(
                Icons.bolt,
                "Log Energy",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: activityCard(
                Icons.eco,
                "Gratitude",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget activityCard(
      IconData icon,
      String title,
      ) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            color: primaryPink,
            size: 35,
          ),

          const SizedBox(height: 10),

          Text(title),

          const SizedBox(height: 10),

          const CircleAvatar(
            radius: 15,
            backgroundColor:
            primaryPink,
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 18,
            ),
          )
        ],
      ),
    );
  }

  Widget buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Column(
        children: [

          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: primaryPink,
                size: 40,
              ),
              const SizedBox(width: 10),

              Text(
                "$streak Day Streak",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,
            children: List.generate(
              7,
                  (index) => CircleAvatar(
                radius: 14,
                backgroundColor:
                index < streak
                    ? primaryPink
                    : Colors.grey.shade300,
                child: index < streak
                    ? const Icon(
                  Icons.check,
                  color:
                  Colors.white,
                  size: 14,
                )
                    : null,
              ),
            ),
          )
        ],
      ),
    );
  }
}