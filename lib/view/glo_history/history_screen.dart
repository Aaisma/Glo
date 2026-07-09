import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glo/model/history_model.dart';
import 'package:glo/view/glo_profile/glo_profile.dart';
import 'package:glo/view/navigation_icon/calendar_screen.dart';
import 'package:glo/view/components/bottom_navigation.dart';
import 'package:glo/viewmodel/history_viewmodel.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const Color pink = Color(0xFFE85D8A);
  static const Color softPink = Color(0xFFFFF7FA);
  static const Color iconBg = Color(0xFFFFEAF1);
  static const Color borderPink = Color(0xFFFFD6E2);
  static const Color dark = Color(0xFF14181F);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  void _onBottomTap(int index) {
    if (index == 3) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/insights');
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CalendarScreen(),
          ),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const GloProfileScreen(),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Screen not connected yet'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: HistoryScreen.softPink,
      bottomNavigationBar: BottomNavigation(
        currentIndex: 3,
        onTap: _onBottomTap,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withValues(alpha: 0.58),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: userId == null
                        ? _buildMessage(
                      icon: Icons.person_outline,
                      title: 'Login required',
                      message: 'Please login to view your history.',
                    )
                        : _buildHistoryList(userId),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Center(
        child: Text(
          'history',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HistoryScreen.pink,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(String userId) {
    final viewModel = context.read<HistoryViewModel>();

    return StreamBuilder<List<HistoryModel>>(
      stream: viewModel.getHistoryStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: HistoryScreen.pink,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildMessage(
            icon: Icons.error_outline,
            title: 'Unable to load history',
            message: snapshot.error.toString(),
          );
        }

        final historyItems = snapshot.data ?? [];

        if (historyItems.isEmpty) {
          return _buildMessage(
            icon: Icons.history,
            title: 'No history yet',
            message: 'Your saved activity will appear here.',
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              ...historyItems.map(
                    (item) => _buildSection(item),
              ),
              const SizedBox(height: 10),
              _exportButton(historyItems),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(HistoryModel item) {
    return GestureDetector(
      onTap: () => _showDetailsDialog(
        item.title,
        item.details,
      ),
      child: _SoftCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _RoundIcon(
              icon: item.icon,
              iconSize: 29,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: HistoryScreen.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...item.content.map(
                        (contentItem) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        contentItem,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1,
                          color: HistoryScreen.dark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(item.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: HistoryScreen.dark.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: HistoryScreen.pink,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportButton(List<HistoryModel> historyItems) {
    return GestureDetector(
      onTap: () {
        context.read<HistoryViewModel>().exportCycleData(
          items: historyItems,
        );
      },
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3F7).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: HistoryScreen.borderPink,
          ),
          boxShadow: [
            BoxShadow(
              color: HistoryScreen.pink.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.file_download_outlined,
              color: HistoryScreen.pink,
              size: 26,
            ),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'Export Cycle Data',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: HistoryScreen.pink,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: _SoftCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: HistoryScreen.pink,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: HistoryScreen.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: HistoryScreen.dark.withValues(alpha: 0.70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(
      String title,
      String details,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: HistoryScreen.softPink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            color: HistoryScreen.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          details.isEmpty ? 'No details available.' : details,
          style: const TextStyle(
            color: HistoryScreen.dark,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: HistoryScreen.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final double iconSize;

  const _RoundIcon({
    required this.icon,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: HistoryScreen.iconBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: HistoryScreen.pink,
        size: iconSize,
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  const _SoftCard({
    required this.child,
    required this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: HistoryScreen.softPink.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: HistoryScreen.borderPink,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}