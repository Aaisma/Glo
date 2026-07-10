import 'package:flutter/material.dart';

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  static const Color pink = Color(0xFFE85D8A);
  static const Color lightPink = Color(0xFFFFF5F9);
  static const Color softPink = Color(0xFFFFEAF2);
  static const Color borderPink = Color(0xFFFFD8E6);
  static const Color darkText = Color(0xFF2C2730);
  static const Color greyText = Color(0xFF6F6570);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPink,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroGoalCard(
                onEditTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit goal coming soon')),
                  );
                },
              ),
              const SizedBox(height: 26),

              const _SectionTitle('Goal Overview'),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _OverviewCard(
                      icon: Icons.water_drop_outlined,
                      title: 'Current Cycle Day',
                      value: '23',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _OverviewCard(
                      icon: Icons.refresh_rounded,
                      title: 'Cycle Length',
                      value: '28 Days',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              const _SectionTitle('Goal Progress'),
              const SizedBox(height: 12),
              const _ProgressCard(),
              const SizedBox(height: 26),

              const _SectionTitle('Goal Focus'),
              const SizedBox(height: 12),
              const _FocusCard(),
              const SizedBox(height: 26),

              const _SectionTitle('Milestones'),
              const SizedBox(height: 12),
              const _MilestonesCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroGoalCard extends StatelessWidget {
  final VoidCallback onEditTap;

  const _HeroGoalCard({
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          Container(
            height: 86,
            width: 86,
            decoration: const BoxDecoration(
              color: GoalScreen.softPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: GoalScreen.pink,
              size: 48,
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Goal',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: GoalScreen.darkText,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Stay consistent, feel my best &\nembrace every step.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.25,
                    color: GoalScreen.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEditTap,
            icon: const Icon(
              Icons.edit_square,
              color: GoalScreen.pink,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: GoalScreen.darkText,
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: GoalScreen.pink,
            size: 42,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: GoalScreen.greyText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              color: GoalScreen.darkText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Progress This Cycle',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: GoalScreen.darkText,
                  ),
                ),
              ),
              Text(
                '23 / 28 Days',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: GoalScreen.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: 23 / 28,
              minHeight: 10,
              backgroundColor: GoalScreen.softPink,
              valueColor: const AlwaysStoppedAnimation<Color>(
                GoalScreen.pink,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Row(
            children: [
              Expanded(
                child: _ProgressStat(
                  icon: Icons.check_circle_outline_rounded,
                  value: '15',
                  label: 'Days Logged',
                ),
              ),
              _SmallVerticalDivider(),
              Expanded(
                child: _ProgressStat(
                  icon: Icons.local_fire_department_outlined,
                  value: '8',
                  label: 'Day Streak',
                ),
              ),
              _SmallVerticalDivider(),
              Expanded(
                child: _ProgressStat(
                  icon: Icons.star_border_rounded,
                  value: '3',
                  label: 'Milestones',
                ),
              ),
              _SmallVerticalDivider(),
              Expanded(
                child: _ProgressStat(
                  icon: Icons.trending_up_rounded,
                  value: '75%',
                  label: 'Completion',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProgressStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _IconBubble(
          icon: icon,
          size: 62,
          iconSize: 32,
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: GoalScreen.darkText,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: GoalScreen.greyText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: const Column(
        children: [
          _FocusTile(
            icon: Icons.track_changes_rounded,
            title: 'Stay Consistent',
            subtitle: 'Build a daily routine and stay on track',
          ),
          _DividerLine(),
          _FocusTile(
            icon: Icons.favorite_border_rounded,
            title: 'Feel My Best',
            subtitle: 'Improve my mood, energy & overall well-being',
          ),
          _DividerLine(),
          _FocusTile(
            icon: Icons.spa_outlined,
            title: 'Embrace Every Step',
            subtitle: 'Be kind to myself and enjoy the journey',
          ),
        ],
      ),
    );
  }
}

class _FocusTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FocusTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: Row(
        children: [
          _IconBubble(
            icon: icon,
            size: 58,
            iconSize: 31,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: GoalScreen.darkText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: GoalScreen.greyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: GoalScreen.pink,
            size: 34,
          ),
        ],
      ),
    );
  }
}

class _MilestonesCard extends StatelessWidget {
  const _MilestonesCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: const Column(
        children: [
          _MilestoneTile(
            title: 'First 7 Days',
            status: 'Completed',
            days: '7 Days',
            date: 'May 01, 2025',
            completed: true,
          ),
          _DividerLine(),
          _MilestoneTile(
            title: '2 Weeks Strong',
            status: 'Completed',
            days: '14 Days',
            date: 'May 08, 2025',
            completed: true,
          ),
          _DividerLine(),
          _MilestoneTile(
            title: '1 Month Goal',
            status: 'In Progress',
            days: '28 Days',
            date: 'May 22, 2025',
            completed: false,
          ),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final String title;
  final String status;
  final String days;
  final String date;
  final bool completed;

  const _MilestoneTile({
    required this.title,
    required this.status,
    required this.days,
    required this.date,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = completed ? GoalScreen.pink : Colors.grey.shade400;
    final iconBg = completed ? GoalScreen.softPink : Colors.grey.shade100;
    final statusColor = completed ? GoalScreen.pink : GoalScreen.pink;

    return SizedBox(
      height: 78,
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: iconColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: GoalScreen.darkText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                days,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: GoalScreen.darkText,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: GoalScreen.greyText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;

  const _IconBubble({
    required this.icon,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        color: GoalScreen.softPink,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: GoalScreen.pink,
        size: iconSize,
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: GoalScreen.borderPink.withValues(alpha: 0.65),
    );
  }
}

class _SmallVerticalDivider extends StatelessWidget {
  const _SmallVerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 86,
      color: GoalScreen.borderPink.withValues(alpha: 0.7),
    );
  }
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double? height;

  const _SoftCard({
    required this.child,
    required this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: GoalScreen.borderPink.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: GoalScreen.pink.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}