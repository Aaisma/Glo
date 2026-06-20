import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"), // your background
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('history')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final historyDocs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyDocs.length,
              itemBuilder: (context, index) {
                final data = historyDocs[index].data() as Map<String, dynamic>;
                return _buildHistoryCard(
                  data['type'] ?? 'Unknown',
                  data['title'] ?? '',
                  data['details'] ?? '',
                  data['date'] ?? '',
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryCard(String type, String title, String details, String date) {
    IconData icon;
    switch (type) {
      case 'medication':
        icon = Icons.medication;
        break;
      case 'visit':
        icon = Icons.local_hospital;
        break;
      case 'cycle':
        icon = Icons.calendar_month;
        break;
      case 'acne':
        icon = Icons.face;
        break;
      case 'mood':
        icon = Icons.mood;
        break;
      case 'journal':
        icon = Icons.book;
        break;
      case 'system':
        icon = Icons.settings;
        break;
      default:
        icon = Icons.history;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 6,
      // ✅ Corrected: use withValues instead of withOpacity
      shadowColor: Colors.pinkAccent.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFFFA9BA), size: 28),
                const SizedBox(width: 10),
                Text(
                  "${type[0].toUpperCase()}${type.substring(1)} History",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("• $title", style: const TextStyle(color: Colors.black87)),
            Text("• $details", style: const TextStyle(color: Colors.black54)),
            Text("• Date: $date", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
