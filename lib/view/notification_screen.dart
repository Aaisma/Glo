// notification.dart
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Active filter tab state: 'All', 'Unread', 'Read'
  String activeTab = 'All';

  // Dynamic stateful dataset matching your UI design perfectly
  List<Map<String, dynamic>> notifications = [
    {
      'id': 1,
      'section': 'Today',
      'title': 'Ovulation in 2 days',
      'tag': 'Ovulation',
      'description': 'Your fertile window is starting soon. Take care! 🌸',
      'time': '9:00 AM',
      'icon': '🌸',
      'iconBg': const Color(0xFFFFE3E6),
      'isUnread': true,
    },
    {
      'id': 2,
      'section': 'Today',
      'title': 'Stay Hydrated!',
      'tag': 'Water Tracker',
      'description': 'Time to drink a glass of water. Keep your body happy! 💧',
      'time': '9:30 AM',
      'icon': '💧',
      'iconBg': const Color(0xFFE3F2FD), // Soft blue for water
      'isUnread': true,
    },
    {
      'id': 3,
      'section': 'Today',
      'title': 'Time to take Iron Supplement',
      'tag': 'Medication',
      'description': 'Consistency is the key to better health. 💊',
      'time': '10:00 AM',
      'icon': '💊',
      'iconBg': const Color(0xFFFFF2CC),
      'isUnread': true,
    },
    {
      'id': 4,
      'section': 'Today',
      'title': 'Don\'t forget to log your mood',
      'tag': 'Mood Tracker',
      'description': 'How are you feeling today?\nYour Mood Garden misses you! 🏡',
      'time': '12:00 PM',
      'icon': '😊',
      'iconBg': const Color(0xFFFFEAA7),
      'isUnread': true,
    },
    {
      'id': 5,
      'section': 'Yesterday',
      'title': 'Derma Visit Tomorrow',
      'tag': 'Derma Visit',
      'description': 'You have a dermatology appointment tomorrow at 10:00 AM.',
      'time': '8:00 PM',
      'icon': '👩‍⚕️',
      'iconBg': const Color(0xFFE3F2FD),
      'isUnread': true,
    },
    {
      'id': 6,
      'section': 'Yesterday',
      'title': 'Water goal achieved! 🎉',
      'tag': 'Water Tracker',
      'description': 'Awesome job! You reached your 2.5L target yesterday.',
      'time': '8:30 PM',
      'icon': '🥤',
      'iconBg': const Color(0xFFE0F7FA), // Soft cyan for completed target
      'isUnread': false,
    },
    {
      'id': 7,
      'section': 'Yesterday',
      'title': 'Period expected in 3 days',
      'tag': 'Period',
      'description': 'Your period is expected on April 06, 2026.',
      'time': '7:00 PM',
      'icon': '🩸',
      'iconBg': const Color(0xFFFFEBEE),
      'isUnread': false,
    },
    {
      'id': 8,
      'section': 'Yesterday',
      'title': 'Period log reminder',
      'tag': 'Period Log',
      'description': 'You haven\'t logged your period today. Update your cycle.',
      'time': '6:00 PM',
      'icon': '📅',
      'iconBg': const Color(0xFFF3E5F5),
      'isUnread': true,
    },
    {
      'id': 9,
      'section': 'Yesterday',
      'title': 'Journal reminder',
      'tag': 'Journal',
      'description': 'Write down your thoughts and feelings of today. ✨',
      'time': '9:00 PM',
      'icon': '📖',
      'iconBg': const Color(0xFFE8F5E9),
      'isUnread': true,
    },
  ];

  void _changeTab(String tabName) {
    setState(() {
      activeTab = tabName;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var item in notifications) {
        item['isUnread'] = false;
      }
    });
  }

  void _clearAllNotifications() {
    setState(() {
      notifications.clear();
    });
  }

  void _toggleSingleReadState(int id) {
    setState(() {
      final index = notifications.indexWhere((element) => element['id'] == id);
      if (index != -1) {
        notifications[index]['isUnread'] = !notifications[index]['isUnread'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredNotifications = notifications.where((item) {
      if (activeTab == 'Unread') return item['isUnread'] == true;
      if (activeTab == 'Read') return item['isUnread'] == false;
      return true;
    }).toList();

    List<Map<String, dynamic>> todayItems = filteredNotifications.where((e) => e['section'] == 'Today').toList();
    List<Map<String, dynamic>> yesterdayItems = filteredNotifications.where((e) => e['section'] == 'Yesterday').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFE3E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_left, color: Color(0xFFD64765)),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE3E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, color: Color(0xFFD64765), size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildTab('All'),
                  _buildTab('Unread'),
                  _buildTab('Read'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          Expanded(
            child: filteredNotifications.isEmpty
                ? const Center(child: Text("No notifications found", style: TextStyle(color: Colors.grey)))
                : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                if (todayItems.isNotEmpty) ...[
                  _buildSectionHeader('Today'),
                  ...todayItems.map((item) => _buildNotificationCard(item)),
                ],
                if (yesterdayItems.isNotEmpty) ...[
                  _buildSectionHeader('Yesterday'),
                  ...yesterdayItems.map((item) => _buildNotificationCard(item)),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _clearAllNotifications,
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFD64765), size: 18),
                  label: const Text('Clear all', style: TextStyle(color: Color(0xFFD64765), fontWeight: FontWeight.w600)),
                ),
              ),
              Container(width: 1, height: 24, color: const Color(0xFFFFCCD3)),
              Expanded(
                child: TextButton.icon(
                  onPressed: _markAllAsRead,
                  icon: const Icon(Icons.done_all, color: Color(0xFFD64765), size: 18),
                  label: const Text('Mark all as read', style: TextStyle(color: Color(0xFFD64765), fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title) {
    final bool isSelected = activeTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeTab(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE96581) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF757575),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE96581),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    bool isUnread = item['isUnread'];

    return GestureDetector(
      onTap: () => _toggleSingleReadState(item['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE96581).withValues(alpha: 0.05),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUnread)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 8.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE96581),
                    shape: BoxShape.circle,
                  ),
                ),
              )
            else
              const SizedBox(width: 14),

            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item['iconBg'],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(item['icon'], style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEFF2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['tag'],
                          style: const TextStyle(
                            color: Color(0xFFE96581),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description'],
                    style: const TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item['time'],
                  style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 10),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (isUnread)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE96581),
                          shape: BoxShape.circle,
                        ),
                      ),
                    const Icon(Icons.chevron_right, color: Color(0xFFFFCCD3), size: 18),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}