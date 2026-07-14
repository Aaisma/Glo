import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/favorites_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../../model/journal_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Color primaryPink = const Color(0xFFFF2D65);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<JournalFavoritesViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);
    final userId = userViewModel.user?.id ?? '';

    return Scaffold(
      backgroundColor: backgroundSoftPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryPink, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<List<JournalModel>>(
          stream: userId.isEmpty ? Stream.value([]) : viewModel.getFavoritesStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No journals found."));
            }

            final favorites = snapshot.data!;

            if (favorites.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_border, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("No favorite journals yet.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            // Sort by date descending
            favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final journal = favorites[index];
                return _buildFavoriteItem(journal);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(JournalModel journal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('dd').format(journal.createdAt),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
              ),
              Text(
                DateFormat('MMM').format(journal.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Text(journal.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  journal.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('hh:mm a').format(journal.createdAt)} • Mood: ${journal.mood}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.star,
              color: primaryPink,
              size: 24,
            ),
            onPressed: () {
              Provider.of<JournalFavoritesViewModel>(context, listen: false)
                  .toggleFavorite(journal);
            },
          ),
        ],
      ),
    );
  }
}
