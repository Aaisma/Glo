import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController controller = TextEditingController();
  final String userId = "demo_user";

  void saveNote() async {
    final date = DateTime.now().toIso8601String().split("T")[0];

    await FirebaseFirestore.instance
        .collection("notes")
        .doc(userId)
        .collection("days")
        .doc(date)
        .set({
      "note": controller.text,
      "date": date,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Note Saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Write your note...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveNote,
              child: const Text("Save Note"),
            ),
          ],
        ),
      ),
    );
  }
}