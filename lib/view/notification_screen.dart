import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gloclone/viewmodel/notification_view_model.dart';
import 'package:gloclone/model/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String selectedTab = "All";

  final Color primaryPink = const Color(0xFFF472B6);
  final Color lightPinkBg = const Color(0xFFFFEBF0);
  final Color backgroundLight = const Color(0xFFFFFBFB);
  final Color textDark = const Color(0xFF262626);
  final Color textGray = const Color(0xFF71717A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NotificationViewModel>(context);
    final List<NotificationModel> filteredList = viewModel.filteredNotifications;

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header Toolbar ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: textDark, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "Notifications",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
                  ),
                  IconButton(
                    icon: Icon(Icons.tune, color: primaryPink),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // --- Interactive Sub-Tabs ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Row(
                children: ["All", "Unread", "Read"].map((tab) {
                  bool isSelected = viewModel.selectedTab == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        viewModel.setSelectedTab(tab);
                      },
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
                            color: isSelected ? Colors.white : textGray,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // --- Dynamic Scrollable List Layout ---
            Expanded(
              child: viewModel.isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryPink))
                  : filteredList.isEmpty
                  ? Center(child: Text("No alerts present under ${viewModel.selectedTab}", style: TextStyle(color: textGray)))
                  : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  bool showDayHeader = index == 0 || filteredList[index - 1].day != item.day;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDayHeader) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 12.0),
                          child: Text(
                            item.day,
                            style: TextStyle(color: primaryPink, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                      GestureDetector(
                        onTap: () {
                          viewModel.markAsRead(item.id);
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.unread) ...[
                                  Container(
                                    margin: const EdgeInsets.only(top: 18.0, right: 8.0),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(color: primaryPink, shape: BoxShape.circle),
                                  ),
                                ],
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(color: Color(0xFFFFF0F3), shape: BoxShape.circle),
                                  child: Center(child: Text(item.icon, style: const TextStyle(fontSize: 22))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.title,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark),
                                          ),
                                          Text(item.time, style: TextStyle(fontSize: 11, color: textGray)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: lightPinkBg, borderRadius: BorderRadius.circular(4)),
                                        child: Text(
                                          item.badge,
                                          style: TextStyle(color: primaryPink, fontSize: 10, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.desc,
                                        style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.35),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right, color: primaryPink, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}