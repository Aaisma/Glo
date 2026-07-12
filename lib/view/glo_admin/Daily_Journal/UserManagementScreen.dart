import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: UserManagementScreen()));

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<Map<String, String>> users = [
    {"name": "Aarohi Sharma", "email": "aarohi@example.com", "joined": "Jul 10, 2026", "status": "Active"},
    {"name": "Isha Verma", "email": "isha@example.com", "joined": "Jul 08, 2026", "status": "Active"},
    {"name": "Diya Karki", "email": "diya@example.com", "joined": "Jul 07, 2026", "status": "Active"},
    {"name": "Nandini Joshi", "email": "nandini@example.com", "joined": "Jul 05, 2026", "status": "Suspended"},
    {"name": "Sara Rai", "email": "sara@example.com", "joined": "Jul 02, 2026", "status": "Active"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search users by name or email...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            _buildFilters(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: users.length,
                itemBuilder: (context, index) => _UserItem(data: users[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Add New User", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(Icons.arrow_back),
          Spacer(),
          Text("User Management", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Spacer(),
          Icon(Icons.notifications_none),
          SizedBox(width: 15),
          Icon(Icons.filter_list),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _FilterChip("All Users", true),
          _FilterChip("Active", false),
          _FilterChip("Suspended", false),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip(this.label, this.isSelected);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.pinkAccent : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
    );
  }
}

class _UserItem extends StatelessWidget {
  final Map<String, String> data;
  const _UserItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(data['email']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text("Joined: ${data['joined']!}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: data['status'] == 'Active' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(data['status']!, style: TextStyle(fontSize: 10, color: data['status'] == 'Active' ? Colors.green : Colors.orange)),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
    );
  }
}