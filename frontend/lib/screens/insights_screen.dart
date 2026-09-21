import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _selectedPeriod = 0;

  final List<String> _periods = [
    '7 Days',
    '30 Days',
    '3 Months',
  ];

  // ============================================================
  // PERIOD DATA
  // ============================================================

  final List<_InsightsData> _insightsData = [
    // ----------------------------------------------------------
    // 7 DAYS
    // ----------------------------------------------------------
    _InsightsData(
      score: 7.4,
      change: '+8%',
      mood: 7.4,
      energy: 6.8,
      sleep: 7.1,
      scoreMessage: 'Your wellbeing score is looking positive.',
      chartLabels: [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ],
      moodValues: [
        5.8,
        6.7,
        6.2,
        7.5,
        7.1,
        8.0,
        8.3,
      ],
      energyValues: [
        5.2,
        5.9,
        6.6,
        6.1,
        6.9,
        7.2,
        7.4,
      ],
      emotions: [
        _EmotionData(
          name: 'Calm',
          value: 0.82,
          icon: Icons.spa_outlined,
        ),
        _EmotionData(
          name: 'Happy',
          value: 0.68,
          icon: Icons.sentiment_satisfied_alt_outlined,
        ),
        _EmotionData(
          name: 'Motivated',
          value: 0.56,
          icon: Icons.rocket_launch_outlined,
        ),
        _EmotionData(
          name: 'Anxious',
          value: 0.38,
          icon: Icons.psychology_outlined,
          negative: true,
        ),
      ],
      insightTitle: 'You’re finding your balance',
      insightText:
      'Your mood has been more positive on days when your '
          'energy and sleep are higher. Keep giving yourself time '
          'to rest and recharge.',
      streak: 6,
      streakGoal: 7,
      streakMessage: 'Keep checking in to build your streak',
      streakDays: [
        true,
        true,
        true,
        true,
        false,
        true,
        true,
      ],
      streakLabels: [
        'M',
        'T',
        'W',
        'T',
        'F',
        'S',
        'S',
      ],
    ),

    // ----------------------------------------------------------
    // 30 DAYS
    // ----------------------------------------------------------
    _InsightsData(
      score: 7.1,
      change: '+5%',
      mood: 7.1,
      energy: 6.5,
      sleep: 6.9,
      scoreMessage:
      'Your overall wellbeing has remained fairly steady.',
      chartLabels: [
        '1',
        '5',
        '10',
        '15',
        '20',
        '25',
        '30',
      ],
      moodValues: [
        6.1,
        6.4,
        6.8,
        7.0,
        6.7,
        7.4,
        7.6,
      ],
      energyValues: [
        5.8,
        6.0,
        6.2,
        6.4,
        6.1,
        6.8,
        7.0,
      ],
      emotions: [
        _EmotionData(
          name: 'Calm',
          value: 0.76,
          icon: Icons.spa_outlined,
        ),
        _EmotionData(
          name: 'Happy',
          value: 0.64,
          icon: Icons.sentiment_satisfied_alt_outlined,
        ),
        _EmotionData(
          name: 'Motivated',
          value: 0.51,
          icon: Icons.rocket_launch_outlined,
        ),
        _EmotionData(
          name: 'Anxious',
          value: 0.44,
          icon: Icons.psychology_outlined,
          negative: true,
        ),
      ],
      insightTitle: 'Your patterns are becoming clearer',
      insightText:
      'Across the last 30 days, calmer days have appeared '
          'more often when your energy and sleep were higher. '
          'Your overall pattern has stayed relatively consistent.',
      streak: 18,
      streakGoal: 30,
      streakMessage: 'You have checked in regularly this month',
      streakDays: [
        true,
        true,
        true,
        false,
        true,
        true,
        true,
      ],
      streakLabels: [
        '1',
        '5',
        '10',
        '15',
        '20',
        '25',
        '30',
      ],
    ),

    // ----------------------------------------------------------
    // 3 MONTHS
    // ----------------------------------------------------------
    _InsightsData(
      score: 7.6,
      change: '+11%',
      mood: 7.6,
      energy: 7.0,
      sleep: 7.3,
      scoreMessage:
      'Your longer-term wellbeing pattern is trending positively.',
      chartLabels: [
        'Jul',
        'Mid Jul',
        'Aug',
        'Mid Aug',
        'Sep',
        'Now',
      ],
      moodValues: [
        6.2,
        6.5,
        6.9,
        7.1,
        7.5,
        8.0,
      ],
      energyValues: [
        5.7,
        6.1,
        6.4,
        6.6,
        6.9,
        7.2,
      ],
      emotions: [
        _EmotionData(
          name: 'Calm',
          value: 0.84,
          icon: Icons.spa_outlined,
        ),
        _EmotionData(
          name: 'Happy',
          value: 0.72,
          icon: Icons.sentiment_satisfied_alt_outlined,
        ),
        _EmotionData(
          name: 'Motivated',
          value: 0.63,
          icon: Icons.rocket_launch_outlined,
        ),
        _EmotionData(
          name: 'Anxious',
          value: 0.31,
          icon: Icons.psychology_outlined,
          negative: true,
        ),
      ],
      insightTitle: 'Your longer-term pattern is improving',
      insightText:
      'Looking across three months, your wellbeing scores '
          'show gradual improvement. Positive emotions have '
          'become more frequent while anxious feelings appear '
          'less often in your recent check-ins.',
      streak: 42,
      streakGoal: 60,
      streakMessage:
      'You have built a consistent long-term check-in habit',
      streakDays: [
        true,
        true,
        true,
        true,
        true,
        true,
        false,
      ],
      streakLabels: [
        'W1',
        'W2',
        'W3',
        'W4',
        'W5',
        'W6',
        'W7',
      ],
    ),
  ];

  _InsightsData get _currentData {
    return _insightsData[_selectedPeriod];
  }

  // ============================================================
  // BUILD
  // ============================================================

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
              child: _buildPeriodSelector(),
            ),

            SliverToBoxAdapter(
              child: _buildOverviewCard(),
            ),

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Your mood pattern',
                _selectedPeriod == 0
                    ? 'See how your mood has changed this week'
                    : _selectedPeriod == 1
                    ? 'See how your mood has changed this month'
                    : 'See how your mood has changed over time',
              ),
            ),

            SliverToBoxAdapter(
              child: _buildMoodChart(),
            ),

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Wellbeing overview',
                'Your recent check-in patterns',
              ),
            ),

            SliverToBoxAdapter(
              child: _buildWellbeingGrid(),
            ),

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'What you’ve been feeling',
                'Emotions appearing in your check-ins',
              ),
            ),

            SliverToBoxAdapter(
              child: _buildEmotionCard(),
            ),

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'MindMate insight',
                'A little reflection based on your check-ins',
              ),
            ),

            SliverToBoxAdapter(
              child: _buildInsightCard(),
            ),

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'Your wellbeing streak',
                'Small steps add up',
              ),
            ),

            SliverToBoxAdapter(
              child: _buildStreakCard(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 30),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        10,
      ),
      child: Row(
        children: [
          // ------------------------------------------------------
          // BACK BUTTON
          // ------------------------------------------------------

          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderMint,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.navy,
                size: 21,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ------------------------------------------------------
          // TITLE
          // ------------------------------------------------------

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Insights',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Understand your wellbeing journey',
                  style: TextStyle(
                    color: Colors.black54,
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

  // ============================================================
  // PERIOD SELECTOR
  // ============================================================

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        18,
      ),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.lightMint,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: List.generate(
            _periods.length,
                (index) {
              final selected = _selectedPeriod == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_selectedPeriod == index) return;

                    setState(() {
                      _selectedPeriod = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 220,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: selected
                          ? [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(
                        milliseconds: 180,
                      ),
                      style: TextStyle(
                        color: selected
                            ? AppColors.navy
                            : Colors.black54,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      child: Text(
                        _periods[index],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OVERVIEW CARD
  // ============================================================

  Widget _buildOverviewCard() {
    final data = _currentData;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.navy,
              Color(0xFF294253),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.16),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -35,
              child: Container(
                width: 115,
                height: 115,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mint.withValues(alpha: 0.12),
                ),
              ),
            ),

            Positioned(
              right: 35,
              bottom: -55,
              child: Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.mint.withValues(
                          alpha: 0.18,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        color: AppColors.mint,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        'Overall wellbeing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Dynamic period change
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mint.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            color: AppColors.mint,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data.change,
                            style: const TextStyle(
                              color: AppColors.mint,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      data.score.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 3,
                      ),
                      child: Text(
                        '/ 10',
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.48,
                          ),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  data.scoreMessage,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.65,
                    ),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 18),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: data.score / 10,
                    minHeight: 7,
                    backgroundColor:
                    Colors.white.withValues(alpha: 0.10),
                    valueColor:
                    const AlwaysStoppedAnimation(
                      AppColors.mint,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      String subtitle,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        26,
        20,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOOD CHART
  // ============================================================

  Widget _buildMoodChart() {
    final data = _currentData;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Container(
        height: 245,
        padding: const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.borderMint,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildLegendDot(
                  AppColors.mint,
                  'Mood',
                ),

                const SizedBox(width: 14),

                _buildLegendDot(
                  AppColors.navy,
                  'Energy',
                ),

                const Spacer(),

                Text(
                  _selectedPeriod == 0
                      ? 'Daily average / 10'
                      : _selectedPeriod == 1
                      ? '30-day trend / 10'
                      : '3-month trend / 10',
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: CustomPaint(
                painter: _MoodChartPainter(
                  moodValues: data.moodValues,
                  energyValues: data.energyValues,
                ),
                child: const SizedBox.expand(),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: data.chartLabels.map(
                    (label) {
                  return Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black38,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(
      Color color,
      String label,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 5),

        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WELLBEING GRID
  // ============================================================

  Widget _buildWellbeingGrid() {
    final data = _currentData;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              icon: Icons.favorite_outline_rounded,
              title: 'Mood',
              value: data.mood.toStringAsFixed(1),
              change: _getMetricChange('mood'),
              positive: true,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: _buildMetricCard(
              icon: Icons.bolt_outlined,
              title: 'Energy',
              value: data.energy.toStringAsFixed(1),
              change: _getMetricChange('energy'),
              positive: true,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: _buildMetricCard(
              icon: Icons.bedtime_outlined,
              title: 'Sleep',
              value: data.sleep.toStringAsFixed(1),
              change: _getMetricChange('sleep'),
              positive: true,
            ),
          ),
        ],
      ),
    );
  }

  String _getMetricChange(String type) {
    if (_selectedPeriod == 0) {
      switch (type) {
        case 'mood':
          return '+0.6';
        case 'energy':
          return '+0.3';
        case 'sleep':
          return '+0.8';
      }
    }

    if (_selectedPeriod == 1) {
      switch (type) {
        case 'mood':
          return '+0.4';
        case 'energy':
          return '+0.2';
        case 'sleep':
          return '+0.5';
      }
    }

    switch (type) {
      case 'mood':
        return '+0.9';
      case 'energy':
        return '+0.7';
      case 'sleep':
        return '+0.6';
    }

    return '+0.0';
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String change,
    required bool positive,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        12,
        14,
        12,
        13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
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

          const SizedBox(height: 13),

          Text(
            title,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Row(
            children: [
              Icon(
                positive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: positive
                    ? AppColors.mint
                    : Colors.redAccent,
                size: 11,
              ),

              const SizedBox(width: 2),

              Text(
                change,
                style: TextStyle(
                  color: positive
                      ? AppColors.mint
                      : Colors.redAccent,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMOTIONS
  // ============================================================

  Widget _buildEmotionCard() {
    final emotions = _currentData.emotions;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.borderMint,
          ),
        ),
        child: Column(
          children: emotions.map(
                (emotion) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: emotion.negative
                            ? const Color(0xFFFFF4F0)
                            : AppColors.lightMint,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Icon(
                        emotion.icon,
                        size: 17,
                        color: emotion.negative
                            ? const Color(0xFFE68A69)
                            : AppColors.mint,
                      ),
                    ),

                    const SizedBox(width: 11),

                    SizedBox(
                      width: 68,
                      child: Text(
                        emotion.name,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: emotion.value,
                          minHeight: 7,
                          backgroundColor:
                          AppColors.lightMint,
                          valueColor:
                          AlwaysStoppedAnimation(
                            emotion.negative
                                ? const Color(0xFFE6A18A)
                                : AppColors.mint,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 9),

                    Text(
                      '${(emotion.value * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // INSIGHT
  // ============================================================

  Widget _buildInsightCard() {
    final data = _currentData;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.lightMint,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.borderMint,
          ),
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.mint,
                size: 21,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    data.insightTitle,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    data.insightText,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11.5,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STREAK
  // ============================================================

  Widget _buildStreakCard() {
    final data = _currentData;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.borderMint,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    borderRadius:
                    BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_outlined,
                    color: AppColors.mint,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data.streak} day streak',
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        data.streakMessage,
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  '${data.streak} / ${data.streakGoal}',
                  style: const TextStyle(
                    color: AppColors.mint,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: List.generate(
                data.streakDays.length,
                    (index) {
                  final completed =
                  data.streakDays[index];

                  return Column(
                    children: [
                      Container(
                        width: 29,
                        height: 29,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: completed
                              ? AppColors.mint
                              : AppColors.lightMint,
                        ),
                        child: completed
                            ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                            : null,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        data.streakLabels[index],
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
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

// ================================================================
// INSIGHTS DATA MODEL
// ================================================================

class _InsightsData {
  final double score;
  final String change;

  final double mood;
  final double energy;
  final double sleep;

  final String scoreMessage;

  final List<String> chartLabels;
  final List<double> moodValues;
  final List<double> energyValues;

  final List<_EmotionData> emotions;

  final String insightTitle;
  final String insightText;

  final int streak;
  final int streakGoal;
  final String streakMessage;

  final List<bool> streakDays;
  final List<String> streakLabels;

  const _InsightsData({
    required this.score,
    required this.change,
    required this.mood,
    required this.energy,
    required this.sleep,
    required this.scoreMessage,
    required this.chartLabels,
    required this.moodValues,
    required this.energyValues,
    required this.emotions,
    required this.insightTitle,
    required this.insightText,
    required this.streak,
    required this.streakGoal,
    required this.streakMessage,
    required this.streakDays,
    required this.streakLabels,
  });
}

// ================================================================
// EMOTION DATA MODEL
// ================================================================

class _EmotionData {
  final String name;
  final double value;
  final IconData icon;
  final bool negative;

  const _EmotionData({
    required this.name,
    required this.value,
    required this.icon,
    this.negative = false,
  });
}

// ================================================================
// MOOD CHART PAINTER
// ================================================================

class _MoodChartPainter extends CustomPainter {
  final List<double> moodValues;
  final List<double> energyValues;

  _MoodChartPainter({
    required this.moodValues,
    required this.energyValues,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final gridPaint = Paint()
      ..color = const Color(0xFFEAF1EE)
      ..strokeWidth = 1;

    final moodPaint = Paint()
      ..color = AppColors.mint
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final energyPaint = Paint()
      ..color = AppColors.navy
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final moodFillPaint = Paint()
      ..color = AppColors.mint.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    const horizontalLines = 4;

    for (int i = 0; i <= horizontalLines; i++) {
      final y = size.height *
          i /
          horizontalLines;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    if (moodValues.isEmpty ||
        energyValues.isEmpty) {
      return;
    }

    final count = moodValues.length;

    Offset pointFor(
        int index,
        double value,
        ) {
      final x = count == 1
          ? size.width / 2
          : index *
          size.width /
          (count - 1);

      final normalized =
      ((value - 4) / 6).clamp(0.0, 1.0);

      final y =
          size.height -
              normalized * size.height;

      return Offset(x, y);
    }

    final moodPath = Path();
    final energyPath = Path();
    final fillPath = Path();

    for (int i = 0; i < count; i++) {
      final moodPoint =
      pointFor(i, moodValues[i]);

      final energyPoint =
      pointFor(i, energyValues[i]);

      if (i == 0) {
        moodPath.moveTo(
          moodPoint.dx,
          moodPoint.dy,
        );

        energyPath.moveTo(
          energyPoint.dx,
          energyPoint.dy,
        );

        fillPath.moveTo(
          moodPoint.dx,
          size.height,
        );

        fillPath.lineTo(
          moodPoint.dx,
          moodPoint.dy,
        );
      } else {
        moodPath.lineTo(
          moodPoint.dx,
          moodPoint.dy,
        );

        energyPath.lineTo(
          energyPoint.dx,
          energyPoint.dy,
        );

        fillPath.lineTo(
          moodPoint.dx,
          moodPoint.dy,
        );
      }
    }

    fillPath.lineTo(
      size.width,
      size.height,
    );

    fillPath.close();

    canvas.drawPath(
      fillPath,
      moodFillPaint,
    );

    canvas.drawPath(
      moodPath,
      moodPaint,
    );

    canvas.drawPath(
      energyPath,
      energyPaint,
    );

    // ------------------------------------------------------------
    // MOOD POINTS
    // ------------------------------------------------------------

    for (int i = 0; i < count; i++) {
      final point =
      pointFor(i, moodValues[i]);

      canvas.drawCircle(
        point,
        4,
        Paint()..color = AppColors.mint,
      );

      canvas.drawCircle(
        point,
        2,
        Paint()..color = Colors.white,
      );
    }

    // ------------------------------------------------------------
    // BASELINE
    // ------------------------------------------------------------

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      gridPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _MoodChartPainter oldDelegate,
      ) {
    return oldDelegate.moodValues != moodValues ||
        oldDelegate.energyValues != energyValues;
  }
}