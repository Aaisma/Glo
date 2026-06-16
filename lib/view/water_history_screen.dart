import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WaterHistoryScreen extends StatelessWidget {
  const WaterHistoryScreen({super.key});

  final String userId = "demo_user";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Water History")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("water_history")
            .doc(userId)
            .collection("days")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();

              return ListTile(
                title: Text("Date: ${data['date']}"),
                subtitle: Text(
                  "Intake: ${data['intake']} L | Goal: ${data['goal']} L",
                ),
              );
            },
          );
        },
      ),
    );
  }
}