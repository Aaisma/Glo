import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/notification_view_model.dart';
import 'package:glo/model/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color primaryPink = Color(0xFFF472B6);
  static const Color appBackground = Color(0xFFFFF5F7);
  static const Color tabUnselectedBg = Color(0xFFF4F4F5);
  static const Color textDark = Color(0xFF3F3F46);
  static const Color textMuted = Color(0xFF71717A);
  static const Color badgeBg = Color(0xFFFFEBF0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();

    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final filteredList = viewModel.filteredNotifications
        .where((item) => item?.createdAt.isAfter(oneWeekAgo))
        .toList();

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBF0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: primaryPink, size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(color: textDark, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBF0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.tune_rounded, color: primaryPink, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSegmentedControl(viewModel),
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryPink, strokeWidth: 2))
                  : filteredList.isEmpty
                  ? _buildEmptyState(viewModel.selectedTab)
                  : _buildNotificationList(filteredList, viewModel),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(NotificationViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: tabUnselectedBg,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        children: ["All", "Unread", "Read"].map((tab) {
          final isSelected = viewModel.selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => viewModel.setSelectedTab(tab),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: isSelected ? primaryPink : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String selectedTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🌸", style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          const Text(
            "Your notification center is clear",
            style: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            "No $selectedTab alerts recorded for this week.",
            style: const TextStyle(color: textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> list, NotificationViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final bool showDayHeader = index == 0 || list[index - 1].day != item.day;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDayHeader)
              Padding(
                padding: const EdgeInsets.only(top: 14.0, bottom: 8.0, left: 4.0),
                child: Text(
                  item.day,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            NotificationCard(
              item: item,
              onTap: () => viewModel.markAsRead(item.id),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBF0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete_outline, color: primaryPink, size: 18),
              label: const Text("Clear all", style: TextStyle(color: primaryPink, fontWeight: FontWeight.w600)),
            ),
          ),
          Container(height: 24, width: 1, color: primaryPink.withOpacity(0.3)),
          Expanded(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.done_all, color: primaryPink, size: 18),
              label: const Text("Mark all as read", style: TextStyle(color: primaryPink, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onTap;

  const NotificationCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              width: 14,
              height: 48,
              child: item.unread
                  ? Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              )
                  : const SizedBox.shrink(),
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFFFEBF0),
              child: Text(item.icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF262626),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.time,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF98989A)),
                          ),
                          const SizedBox(height: 8),
                          if (item.unread)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBF0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.badge,
                          style: const TextStyle(
                            color: Color(0xFFF472B6),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.desc,
                    style: const TextStyle(
                      color: Color(0xFF52525B),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(top: 14.0),
              child: Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFC0D3), size: 14),
            ),
          ],
        ),
      ),
    );
  }
}