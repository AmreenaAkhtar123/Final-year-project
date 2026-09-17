import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // Demo data for now.
  // Later these values will come from the backend/database.
  final int _checkInsCompleted = 18;
  final int _currentStreak = 6;
  final int _longestStreak = 12;
  final int _assessmentsCompleted = 4;
  final int _aiConversations = 23;
  final double _monthlyGoalProgress = 0.72;

  final List<bool> _activityDays = [
    true,
    true,
    false,
    true,
    true,
    true,
    false,
    true,
    false,
    true,
    true,
    true,
    true,
    false,
    true,
    true,
    false,
    true,
    true,
    false,
    true,
    true,
    true,
    false,
    true,
    true,
    true,
    false,
    true,
    true,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Progress',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.navy,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 22),

              _buildStreakCard(),
              const SizedBox(height: 20),

              _buildSectionTitle('Your Activity'),
              const SizedBox(height: 12),

              _buildActivityCalendar(),
              const SizedBox(height: 22),

              _buildSectionTitle('Your Progress'),
              const SizedBox(height: 12),

              _buildProgressGrid(),
              const SizedBox(height: 22),

              _buildSectionTitle('Monthly Goal'),
              const SizedBox(height: 12),

              _buildGoalCard(),
              const SizedBox(height: 22),

              _buildSectionTitle('Milestones'),
              const SizedBox(height: 12),

              _buildMilestones(),
              const SizedBox(height: 22),

              _buildPrivacyNote(),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keep moving forward 🌱',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Track your wellbeing journey and celebrate your progress.',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.60),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // STREAK
  // ------------------------------------------------------------

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            AppColors.navy.withValues(alpha: 0.90),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.mint,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Streak',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You are building a healthy habit!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_currentStreak',
                    style: const TextStyle(
                      color: AppColors.mint,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'days',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(
            color: Colors.white.withValues(alpha: 0.10),
            height: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStreakInfo(
                  icon: Icons.calendar_month_rounded,
                  label: 'Longest streak',
                  value: '$_longestStreak days',
                ),
              ),
              Container(
                width: 1,
                height: 34,
                color: Colors.white.withValues(alpha: 0.10),
              ),
              Expanded(
                child: _buildStreakInfo(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Check-ins',
                  value: '$_checkInsCompleted',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 18,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 9.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // ACTIVITY CALENDAR
  // ------------------------------------------------------------

  Widget _buildActivityCalendar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.mint,
                size: 19,
              ),
              const SizedBox(width: 9),
              const Text(
                'September Activity',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$_checkInsCompleted check-ins',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.50),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),

          // Weekday labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _DayLabel('M'),
              _DayLabel('T'),
              _DayLabel('W'),
              _DayLabel('T'),
              _DayLabel('F'),
              _DayLabel('S'),
              _DayLabel('S'),
            ],
          ),

          const SizedBox(height: 9),

          // Activity boxes
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _activityDays
                .map(
                  (completed) => _buildActivityBox(completed),
            )
                .toList(),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem(
                color: AppColors.lightMint,
                label: 'No activity',
              ),
              const SizedBox(width: 14),
              _buildLegendItem(
                color: AppColors.mint,
                label: 'Completed',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBox(bool completed) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: completed
            ? AppColors.mint
            : AppColors.lightMint,
        borderRadius: BorderRadius.circular(7),
      ),
      child: completed
          ? const Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 15,
      )
          : null,
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.50),
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PROGRESS GRID
  // ------------------------------------------------------------

  Widget _buildProgressGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      children: [
        _buildProgressCard(
          icon: Icons.favorite_outline_rounded,
          title: 'Check-ins',
          value: '$_checkInsCompleted',
          subtitle: 'completed',
        ),
        _buildProgressCard(
          icon: Icons.assignment_outlined,
          title: 'Assessments',
          value: '$_assessmentsCompleted',
          subtitle: 'completed',
        ),
        _buildProgressCard(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'AI Chats',
          value: '$_aiConversations',
          subtitle: 'conversations',
        ),
        _buildProgressCard(
          icon: Icons.local_fire_department_outlined,
          title: 'Best Streak',
          value: '$_longestStreak',
          subtitle: 'days',
        ),
      ],
    );
  }

  Widget _buildProgressCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.mint,
              size: 18,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.45),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.65),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MONTHLY GOAL
  // ------------------------------------------------------------

  Widget _buildGoalCard() {
    final percentage = (_monthlyGoalProgress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  color: AppColors.mint,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Check-in Goal',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '25 check-ins this month',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _monthlyGoalProgress,
              minHeight: 9,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '$_checkInsCompleted of 25 check-ins completed',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.55),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MILESTONES
  // ------------------------------------------------------------

  Widget _buildMilestones() {
    return Column(
      children: [
        _buildMilestoneCard(
          icon: Icons.flag_rounded,
          title: 'First Check-in',
          subtitle: 'You completed your first wellbeing check-in.',
          completed: true,
        ),
        const SizedBox(height: 10),
        _buildMilestoneCard(
          icon: Icons.local_fire_department_rounded,
          title: '7 Day Streak',
          subtitle: 'Complete 7 consecutive days of check-ins.',
          completed: _longestStreak >= 7,
        ),
        const SizedBox(height: 10),
        _buildMilestoneCard(
          icon: Icons.emoji_events_outlined,
          title: '25 Check-ins',
          subtitle: 'Complete 25 wellbeing check-ins.',
          completed: _checkInsCompleted >= 25,
        ),
      ],
    );
  }

  Widget _buildMilestoneCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool completed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: completed
              ? AppColors.borderMint
              : AppColors.borderMint.withValues(alpha: 0.60),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.lightMint
                  : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed
                  ? Icons.check_rounded
                  : icon,
              color: completed
                  ? AppColors.mint
                  : AppColors.navy.withValues(alpha: 0.35),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.48),
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (completed)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // ------------------------------------------------------------
  // PRIVACY NOTE
  // ------------------------------------------------------------

  Widget _buildPrivacyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.mint,
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Your progress is private and is only used to help '
                  'you understand and build healthy wellbeing habits.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.55),
                fontSize: 9.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// SMALL WEEKDAY LABEL
// ------------------------------------------------------------

class _DayLabel extends StatelessWidget {
  final String label;

  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.navy.withValues(alpha: 0.40),
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}