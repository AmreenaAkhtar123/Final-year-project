import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // ---------------------------------------------------------------------------
  // TEMPORARY DATA
  // We will connect these values to real MindMate data next.
  // ---------------------------------------------------------------------------

  final int _journeyScore = 82;

  final int _totalCheckIns = 18;
  final int _bestStreak = 12;

  final int _mostReflectiveWeek = 6;
  final String _mostActivePeriod = 'September';
  final int _aiInsights = 9;

  final double _reflectionProgress = 0.72;
  final double _consistencyProgress = 0.84;
  final double _selfAwarenessProgress = 0.78;

  final int _completedMilestones = 4;

  final List<int> _weeklyCheckIns = [2, 4, 3, 5, 6];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            SliverToBoxAdapter(
              child: _buildJourneyScore(),
            ),

            SliverToBoxAdapter(
              child: _buildQuickStats(),
            ),

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Personal Records',
                'The milestones that define your journey',
              ),
            ),

            SliverToBoxAdapter(
              child: _buildPersonalRecords(),
            ),

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Consistency Journey',
                'Your check-in rhythm over recent weeks',
              ),
            ),

            SliverToBoxAdapter(
              child: _buildConsistencyChart(),
            ),

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Self-Awareness',
                'How your reflection habits are developing',
              ),
            ),

            SliverToBoxAdapter(
              child: _buildSelfAwareness(),
            ),

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Milestone Roadmap',
                'Small achievements that build your journey',
              ),
            ),

            SliverToBoxAdapter(
              child: _buildMilestoneRoadmap(),
            ),

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Your Journey',
                'Important moments from your MindMate experience',
              ),
            ),

            SliverToBoxAdapter(
              child: _buildJourneyTimeline(),
            ),

            SliverToBoxAdapter(
              child: _buildNextMilestone(),
            ),

            SliverToBoxAdapter(
              child: _buildPrivacyNote(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 28),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackButton(),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Growth Journey 🌱',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'See how your MindMate journey has evolved over time.',
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.58),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).maybePop();
        },
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderMint,
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.navy,
            size: 17,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // JOURNEY SCORE
  // ---------------------------------------------------------------------------

  Widget _buildJourneyScore() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightMint,
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.045),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR JOURNEY',
                      style: TextStyle(
                        color: AppColors.mint,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Journey Score',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'A snapshot of your overall engagement with MindMate.',
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.58),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 18),

              _buildScoreCircle(),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Great momentum — keep building your journey.',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.mint,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle() {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: _ScorePainter(
          progress: _journeyScore / 100,
          backgroundColor: AppColors.borderMint,
          progressColor: AppColors.mint,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_journeyScore',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'SCORE',
                style: TextStyle(
                  color: AppColors.navy.withOpacity(0.48),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // QUICK STATS
  // ---------------------------------------------------------------------------

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickStatCard(
              value: '$_totalCheckIns',
              label: 'Check-ins',
              icon: Icons.edit_note_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickStatCard(
              value: '$_bestStreak',
              label: 'Best streak',
              icon: Icons.local_fire_department_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: AppColors.mint,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.52),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(
      String title,
      String subtitle,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.52),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PERSONAL RECORDS
  // ---------------------------------------------------------------------------

  Widget _buildPersonalRecords() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRecordRow(
            icon: Icons.emoji_events_rounded,
            title: 'Longest streak',
            value: '$_bestStreak days',
          ),
          _buildDivider(),
          _buildRecordRow(
            icon: Icons.edit_note_rounded,
            title: 'Most reflections in a week',
            value: '$_mostReflectiveWeek',
          ),
          _buildDivider(),
          _buildRecordRow(
            icon: Icons.calendar_month_rounded,
            title: 'Most active period',
            value: _mostActivePeriod,
          ),
          _buildDivider(),
          _buildRecordRow(
            icon: Icons.auto_awesome_rounded,
            title: 'MindMate insights',
            value: '$_aiInsights',
          ),
        ],
      ),
    );
  }

  Widget _buildRecordRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: AppColors.mint,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderMint.withOpacity(0.65),
    );
  }

  // ---------------------------------------------------------------------------
  // CONSISTENCY CHART
  // ---------------------------------------------------------------------------

  Widget _buildConsistencyChart() {
    final int highest = _weeklyCheckIns.reduce(math.max);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart_rounded,
                color: AppColors.mint,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Check-in rhythm',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Last 5 weeks',
                style: TextStyle(
                  color: AppColors.navy.withOpacity(0.45),
                  fontSize: 10.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 170,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                _weeklyCheckIns.length,
                    (index) {
                  final value = _weeklyCheckIns[index];
                  final isHighest = value == highest;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$value',
                            style: TextStyle(
                              color: isHighest
                                  ? AppColors.mint
                                  : AppColors.navy.withOpacity(0.55),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: 28,
                                height: 105 * (value / highest),
                                decoration: BoxDecoration(
                                  color: isHighest
                                      ? AppColors.mint
                                      : AppColors.lightMint,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'W${index + 1}',
                            style: TextStyle(
                              color: AppColors.navy.withOpacity(0.45),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 5),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.mint,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your most active week had $highest check-ins.',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SELF-AWARENESS
  // ---------------------------------------------------------------------------

  Widget _buildSelfAwareness() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          _buildProgressMetric(
            icon: Icons.edit_note_rounded,
            title: 'Reflection habit',
            value: _reflectionProgress,
          ),
          const SizedBox(height: 19),
          _buildProgressMetric(
            icon: Icons.event_repeat_rounded,
            title: 'Check-in consistency',
            value: _consistencyProgress,
          ),
          const SizedBox(height: 19),
          _buildProgressMetric(
            icon: Icons.psychology_alt_rounded,
            title: 'Self-awareness',
            value: _selfAwarenessProgress,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressMetric({
    required IconData icon,
    required String title,
    required double value,
  }) {
    final percentage = (value * 100).round();

    return Column(
      children: [
        Row(
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
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: AppColors.lightMint,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.mint,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MILESTONE ROADMAP
  // ---------------------------------------------------------------------------

  Widget _buildMilestoneRoadmap() {
    final milestones = [
      _Milestone(
        title: 'First check-in',
        subtitle: 'You started your MindMate journey',
        icon: Icons.flag_rounded,
        completed: true,
      ),
      _Milestone(
        title: '7-day streak',
        subtitle: 'You built your first consistency streak',
        icon: Icons.local_fire_department_rounded,
        completed: true,
      ),
      _Milestone(
        title: '10 reflections',
        subtitle: 'You made space for personal reflection',
        icon: Icons.edit_note_rounded,
        completed: true,
      ),
      _Milestone(
        title: 'First assessment',
        subtitle: 'You explored your wellbeing further',
        icon: Icons.assignment_rounded,
        completed: true,
      ),
      _Milestone(
        title: '30 check-ins',
        subtitle: '$_totalCheckIns / 30 completed',
        icon: Icons.rocket_launch_rounded,
        completed: false,
      ),
      _Milestone(
        title: '30-day consistency',
        subtitle: 'Keep returning to your journey',
        icon: Icons.calendar_month_rounded,
        completed: false,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: List.generate(
          milestones.length,
              (index) {
            final milestone = milestones[index];
            final isLast = index == milestones.length - 1;

            return _buildMilestoneItem(
              milestone,
              isLast,
            );
          },
        ),
      ),
    );
  }

  Widget _buildMilestoneItem(
      _Milestone milestone,
      bool isLast,
      ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: milestone.completed
                        ? AppColors.mint
                        : AppColors.lightMint,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: milestone.completed
                          ? AppColors.mint
                          : AppColors.borderMint,
                    ),
                  ),
                  child: Icon(
                    milestone.completed
                        ? Icons.check_rounded
                        : milestone.icon,
                    color: milestone.completed
                        ? Colors.white
                        : AppColors.mint,
                    size: 17,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: milestone.completed
                          ? AppColors.mint.withOpacity(0.45)
                          : AppColors.borderMint,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 2,
                bottom: 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    milestone.subtitle,
                    style: TextStyle(
                      color: AppColors.navy.withOpacity(0.52),
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // JOURNEY TIMELINE
  // ---------------------------------------------------------------------------

  Widget _buildJourneyTimeline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          _buildTimelineItem(
            icon: Icons.flag_rounded,
            title: 'Started your MindMate journey',
            description: 'You completed your first check-in.',
            completed: true,
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.assignment_rounded,
            title: 'Explored self-awareness',
            description: 'You completed your first assessment.',
            completed: true,
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.local_fire_department_rounded,
            title: 'Built a consistent habit',
            description: 'You reached a 7-day streak.',
            completed: true,
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.emoji_events_rounded,
            title: 'Reached your longest streak',
            description: 'Your personal record is $_bestStreak days.',
            completed: true,
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.rocket_launch_rounded,
            title: 'Your next milestone',
            description: 'Reach 30 total check-ins.',
            completed: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String description,
    required bool completed,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: completed
                        ? AppColors.lightMint
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: completed
                          ? AppColors.mint
                          : AppColors.borderMint,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: completed
                        ? AppColors.mint
                        : AppColors.navy.withOpacity(0.35),
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.borderMint,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 1,
                bottom: 19,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: completed
                          ? AppColors.navy
                          : AppColors.navy.withOpacity(0.55),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.navy.withOpacity(0.48),
                      fontSize: 10.8,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NEXT MILESTONE
  // ---------------------------------------------------------------------------

  Widget _buildNextMilestone() {
    const target = 30;
    final completed = _totalCheckIns.clamp(0, target);
    final progress = completed / target;
    final remaining = target - completed;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.mint,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              const Text(
                'NEXT MILESTONE',
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            '30 Check-ins',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '$completed / $target completed',
            style: TextStyle(
              color: Colors.white.withOpacity(0.62),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 15),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '$remaining more check-ins to unlock',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.58),
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PRIVACY NOTE
  // ---------------------------------------------------------------------------

  Widget _buildPrivacyNote() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withOpacity(0.65),
        borderRadius: BorderRadius.circular(17),
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
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your progress is personal. MindMate uses your activity to show your journey and milestones.',
              style: TextStyle(
                color: AppColors.navy.withOpacity(0.62),
                fontSize: 10.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SCORE PAINTER
// =============================================================================

class _ScorePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _ScorePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = math.min(
      size.width,
      size.height,
    ) /
        2 -
        6;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScorePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// =============================================================================
// MILESTONE MODEL
// =============================================================================

class _Milestone {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool completed;

  const _Milestone({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.completed,
  });
}