import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:glo/viewmodel/admin_wellness_viewmodel.dart';
import 'package:glo/model/user_model.dart';
import 'package:glo/model/user_model_mood.dart';

class UserWellnessScreen extends StatefulWidget {
  const UserWellnessScreen({super.key});

  @override
  State<UserWellnessScreen> createState() => _UserWellnessScreenState();
}

class _UserWellnessScreenState extends State<UserWellnessScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "All";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminWellnessViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildFilterChips(),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<UserModel>>(
                  stream: viewModel.getAllUsers(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
                      return const Center(child: Text("No users found."));
                    }

                    return StreamBuilder<List<UserModelMood>>(
                      stream: viewModel.getAllMoodLogs(),
                      builder: (context, moodSnapshot) {
                        final allUsers = userSnapshot.data!;
                        final allMoods = moodSnapshot.data ?? [];

                        final filteredUsers = allUsers.where((user) {
                          // Search by name
                          final nameMatch = user.name.toLowerCase().contains(_searchController.text.toLowerCase());
                          if (!nameMatch) return false;

                          if (_selectedFilter == "All") return true;

                          // Filter by user's latest mood status
                          final userMoods = allMoods.where((m) => m.userId == user.id).toList();
                          if (userMoods.isEmpty) return false;
                          
                          userMoods.sort((a, b) => b.date.compareTo(a.date));
                          return userMoods.first.moodType == _selectedFilter;
                        }).toList();

                        return ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            
                            // Correctly link moods to users using the userId field
                            final userMoods = allMoods.where((m) => m.userId == user.id).toList();
                            userMoods.sort((a, b) => b.date.compareTo(a.date));
                            final latestMood = userMoods.isNotEmpty ? userMoods.first : null;

                            return _buildUserCard(user, latestMood);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const Text("User Wellness", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Icon(Icons.filter_list),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() {}),
        decoration: const InputDecoration(
          icon: Icon(Icons.search), 
          hintText: "Search users...", 
          border: InputBorder.none
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ["All", "Amazing", "Happy", "Calm", "Sad", "Angry"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(f), 
            selected: _selectedFilter == f,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = f;
              });
            },
            selectedColor: Colors.pink.shade100,
            backgroundColor: Colors.white,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildUserCard(UserModel user, UserModelMood? latestMood) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.pink.shade50,
            backgroundImage: (user.imageUrl != null && user.imageUrl!.isNotEmpty) ? NetworkImage(user.imageUrl!) : null,
            child: (user.imageUrl == null || user.imageUrl!.isEmpty) ? const Icon(Icons.person, color: Colors.pinkAccent) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  latestMood != null 
                    ? "${DateFormat('MMM dd, hh:mm a').format(latestMood.date)} • ${latestMood.moodType}"
                    : "No recent activity", 
                  style: const TextStyle(fontSize: 12, color: Colors.grey)
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                user.surveyCompleted ? "89%" : "N/A",
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: user.surveyCompleted ? Colors.green : Colors.grey
                )
              ),
              const Text("Score", style: TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
