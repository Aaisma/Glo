import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodel/favorites_viewmodel.dart';
import '../../model/journal_entry_model.dart';


void main() => runApp(const MaterialApp(home: FavoritesScreen()));

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text("Favorites", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4, // Replace with your list length
        separatorBuilder: (context, index) => const Divider(color: Colors.black12),
        itemBuilder: (context, index) {
          return _buildFavoriteItem(
            title: ["Feeling Better Today", "A Day Full of Gratitude", "Overcame My Fear", "Good Things Take Time"][index],
            date: ["July 10, 2026", "July 5, 2026", "June 28, 2026", "June 20, 2026"][index],
            mood: ["Happy", "Grateful", "Proud", "Hopeful"][index],
          );
        },
      ),
    );
  }

  Widget _buildFavoriteItem({required String title, required String date, required String mood}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text("$date • $mood", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const Icon(Icons.star, color: Color(0xFFFF6B81)),
        ],
      ),
    );
  }
}