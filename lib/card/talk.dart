import 'package:flutter/material.dart';

class TalkCard extends StatefulWidget {
  const TalkCard({super.key});

  @override
  State<TalkCard> createState() => _TalkCardState();
}

class _TalkCardState extends State<TalkCard> {
  final TextEditingController _controller = TextEditingController();
  String note = "";

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Talk about your day",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Write your thoughts, feelings or anything...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3E63)),
              onPressed: () {
                setState(() {
                  note = _controller.text;
                });
              },
              child: const Text("Add Note"),
            ),
            if (note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Your Note: $note"),
              ),
          ],
        ),
      ),
    );
  }
}
