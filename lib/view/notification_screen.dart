import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';
import '../widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  Map<String, List<NotificationModel>> _groupNotifications(List<NotificationModel> list) {
    final Map<String, List<NotificationModel>> groups = {'Today': [], 'Yesterday': []};
    final now = DateTime.now();

    for (var item in list) {
      if (item.timestamp.year == now.year &&
          item.timestamp.month == now.month &&
          item.timestamp.day == now.day) {
        groups['Today']!.add(item);
      } else {
        groups['Yesterday']!.add(item);
      }
    }
    return groups;
  }

  Widget _buildPill(String title, NotificationTabFilter filter, NotificationProvider provider) {
    final isSelected = provider.currentFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.changeFilter(filter),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEC407A) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final grouped = _groupNotifications(provider.filteredNotifications);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontFamily: 'Serif', color: Colors.black, fontSize: 22, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildPill('All', NotificationTabFilter.all, provider),
                const SizedBox(width: 8),
                _buildPill('Unread', NotificationTabFilter.unread, provider),
                const SizedBox(width: 8),
                _buildPill('Read', NotificationTabFilter.read, provider),
              ],
            ),
          ),
          Expanded(
            child: provider.filteredNotifications.isEmpty
                ? const Center(child: Text("No notifications found"))
                : ListView(
              children: [
                if (grouped['Today']!.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                    child: Text('Today', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  ...grouped['Today']!.map((n) => NotificationCard(
                    notification: n,
                    onTap: () => provider.markAsRead(n.id),
                  )),
                ],
                if (grouped['Yesterday']!.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 16, bottom: 4),
                    child: Text('Yesterday', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  ...grouped['Yesterday']!.map((n) => NotificationCard(
                    notification: n,
                    onTap: () => provider.markAsRead(n.id),
                  )),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF5F7),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => provider.clearAll(),
                  icon: const Icon(Icons.delete_outline, color: Colors.pinkAccent, size: 20),
                  label: const Text('Clear all', style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.w600)),
                ),
                TextButton.icon(
                  onPressed: () => provider.markAllAsRead(),
                  icon: const Icon(Icons.done_all, color: Colors.pinkAccent, size: 20),
                  label: const Text('Mark all as read', style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
