import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/services/check_in_service.dart';
import '../models/check_in.dart';
import 'home_screen.dart';

class InsightsScreen extends StatefulWidget {
  final VoidCallback onBackToHome;

  const InsightsScreen({
    super.key,
    required this.onBackToHome,
  });

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _selectedPeriod = 0;

  List<CheckIn> _checkIns = [];
  bool _isLoadingCheckIns = true;
  String? _checkInError;

  final List<String> _periods = [
    '7 Days',
    '30 Days',
    '3 Months',
  ];

  _InsightsData _buildInsightsFromCheckIns() {
    final now = DateTime.now();

    final DateTime startDate;

    switch (_selectedPeriod) {
      case 0:
        startDate = now.subtract(const Duration(days: 7));
        break;

      case 1:
        startDate = now.subtract(const Duration(days: 30));
        break;

      default:
        startDate = now.subtract(const Duration(days: 90));
        break;
    }

    final periodCheckIns = _checkIns.where((checkIn) {
      return !checkIn.createdAt.isBefore(startDate);
    }).toList();

    if (periodCheckIns.isEmpty) {
      return _insightsData[_selectedPeriod];
    }

    periodCheckIns.sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
    );

    final moodAverage = periodCheckIns
        .map((checkIn) => _moodToValue(checkIn.mood))
        .reduce((a, b) => a + b) /
        periodCheckIns.length;

    final energyAverage = periodCheckIns
        .map((checkIn) => checkIn.energyLevel.toDouble())
        .reduce((a, b) => a + b) /
        periodCheckIns.length;

    final sleepAverage = periodCheckIns
        .map((checkIn) => checkIn.sleepQuality.toDouble())
        .reduce((a, b) => a + b) /
        periodCheckIns.length;

    final score =
        (moodAverage + energyAverage + sleepAverage) / 3;

    double overallScoreChange = 0;

    if (periodCheckIns.length >= 2) {
      final firstCheckIn = periodCheckIns.first;
      final lastCheckIn = periodCheckIns.last;

      final firstMood =
      _moodToValue(firstCheckIn.mood);

      final firstScore =
          (firstMood +
              firstCheckIn.energyLevel +
              firstCheckIn.sleepQuality) /
              3;

      final lastMood =
      _moodToValue(lastCheckIn.mood);

      final lastScore =
          (lastMood +
              lastCheckIn.energyLevel +
              lastCheckIn.sleepQuality) /
              3;

      overallScoreChange = lastScore - firstScore;
    }

    final moodValues = periodCheckIns
        .map((checkIn) => _moodToValue(checkIn.mood))
        .toList();

    final energyValues = periodCheckIns
        .map((checkIn) => checkIn.energyLevel.toDouble())
        .toList();

    final chartLabels = periodCheckIns.map((checkIn) {
      final date = checkIn.createdAt;

      if (_selectedPeriod == 0) {
        const days = [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun',
        ];

        return days[date.weekday - 1];
      }

      if (_selectedPeriod == 1) {
        return '${date.day}';
      }

      return _monthName(date.month);
    }).toList();

    final emotionCounts = <String, int>{};

    for (final checkIn in periodCheckIns) {
      for (final emotion in checkIn.emotions) {
        emotionCounts[emotion] =
            (emotionCounts[emotion] ?? 0) + 1;
      }
    }

    final totalEmotionSelections = emotionCounts.values.fold(
      0,
          (sum, value) => sum + value,
    );

    final sortedEmotions = emotionCounts.entries.toList()
      ..sort(
            (a, b) => b.value.compareTo(a.value),
      );

    final emotions = sortedEmotions.take(4).map((entry) {
      final percentage = totalEmotionSelections == 0
          ? 0.0
          : entry.value / totalEmotionSelections;

      return _EmotionData(
        name: entry.key,
        value: percentage,
        icon: _emotionIcon(entry.key),
        negative: _isNegativeEmotion(entry.key),
      );
    }).toList();

    while (emotions.length < 4) {
      emotions.add(
        const _EmotionData(
          name: 'No data',
          value: 0,
          icon: Icons.remove_circle_outline,
        ),
      );
    }

    final streak = _calculateStreak();

    return _InsightsData(
      score: score,
      change: overallScoreChange >= 0
          ? '+${overallScoreChange.toStringAsFixed(1)}'
          : overallScoreChange.toStringAsFixed(1),
      mood: moodAverage,
      energy: energyAverage,
      sleep: sleepAverage,
      scoreMessage: _scoreMessage(score),
      chartLabels: chartLabels,
      moodValues: moodValues,
      energyValues: energyValues,
      emotions: emotions,
      insightTitle: _insightTitle(score),
      insightText: _insightText(
        moodAverage,
        energyAverage,
        sleepAverage,
      ),
      streak: streak,
      streakGoal: _selectedPeriod == 0
          ? 7
          : _selectedPeriod == 1
          ? 30
          : 90,
      streakMessage: _streakMessage(streak),
      streakDays: _buildStreakDays(),
      streakLabels: _buildStreakLabels(),
    );
  }

  double _moodToValue(String mood) {
    switch (mood.toLowerCase()) {
      case 'low':
        return 2.0;

      case 'okay':
        return 4.0;

      case 'neutral':
        return 5.0;

      case 'good':
        return 7.0;

      case 'great':
        return 9.0;

      default:
        return 5.0;
    }
  }

  String _monthName(int month) {
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

    return months[month - 1];
  }

  IconData _emotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'calm':
        return Icons.spa_outlined;

      case 'happy':
        return Icons.sentiment_satisfied_alt_outlined;

      case 'motivated':
        return Icons.rocket_launch_outlined;

      case 'anxious':
        return Icons.psychology_outlined;

      case 'sad':
        return Icons.sentiment_dissatisfied_outlined;

      case 'stressed':
        return Icons.warning_amber_outlined;

      case 'angry':
        return Icons.mood_bad_outlined;

      case 'lonely':
        return Icons.person_outline;

      case 'overwhelmed':
        return Icons.psychology_alt_outlined;

      case 'hopeful':
        return Icons.wb_sunny_outlined;

      default:
        return Icons.mood_outlined;
    }
  }

  bool _isNegativeEmotion(String emotion) {
    const negativeEmotions = {
      'anxious',
      'sad',
      'stressed',
      'angry',
      'lonely',
      'overwhelmed',
    };

    return negativeEmotions.contains(
      emotion.toLowerCase(),
    );
  }

  String _scoreMessage(double score) {
    if (score >= 8) {
      return 'Your recent wellbeing has been strong.';
    }

    if (score >= 6) {
      return 'Your recent wellbeing is looking steady.';
    }

    if (score >= 4) {
      return 'Your wellbeing has some room for care and attention.';
    }

    return 'Your recent check-ins suggest you may need some extra care.';
  }

  String _insightTitle(double score) {
    if (score >= 8) {
      return 'You’re building a positive pattern';
    }

    if (score >= 6) {
      return 'Your patterns are becoming clearer';
    }

    if (score >= 4) {
      return 'Your check-ins reveal useful patterns';
    }

    return 'Your check-ins are worth paying attention to';
  }

  String _insightText(
      double mood,
      double energy,
      double sleep,
      ) {
    if (energy >= 7 && sleep >= 7) {
      return 'Your recent check-ins show that your energy and sleep '
          'have been relatively strong. Keep making space for rest '
          'and activities that help you feel balanced.';
    }

    if (sleep < 5) {
      return 'Your recent sleep ratings have been lower. Giving '
          'yourself more opportunities for rest may help support '
          'your overall wellbeing.';
    }

    if (energy < 5) {
      return 'Your recent energy ratings have been lower. Small '
          'breaks, rest, and manageable activities may help you '
          'take care of yourself.';
    }

    return 'Your check-ins are helping reveal how your mood, '
        'energy, and sleep relate over time.';
  }

  String _streakMessage(int streak) {
    if (streak == 0) {
      return 'Start checking in to build your streak';
    }

    if (streak == 1) {
      return 'Keep checking in tomorrow';
    }

    return 'Keep checking in to build your streak';
  }

  int _calculateStreak() {
    if (_checkIns.isEmpty) {
      return 0;
    }

    final dates = _checkIns
        .map(
          (checkIn) => DateTime(
        checkIn.createdAt.year,
        checkIn.createdAt.month,
        checkIn.createdAt.day,
      ),
    )
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) {
      return 0;
    }

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // If the user has not checked in today, start from yesterday.
    DateTime currentDate;

    if (dates.first == today) {
      currentDate = today;
    } else if (dates.first == today.subtract(
      const Duration(days: 1),
    )) {
      currentDate = today.subtract(
        const Duration(days: 1),
      );
    } else {
      return 0;
    }

    int streak = 0;

    for (final date in dates) {
      if (date == currentDate) {
        streak++;
        currentDate = currentDate.subtract(
          const Duration(days: 1),
        );
      } else if (date.isBefore(currentDate)) {
        break;
      }
    }

    return streak;
  }

  List<bool> _buildStreakDays() {
    final now = DateTime.now();

    final int numberOfDays;

    switch (_selectedPeriod) {
      case 0:
        numberOfDays = 7;
        break;

      case 1:
        numberOfDays = 7;
        break;

      default:
        numberOfDays = 7;
        break;
    }

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final checkInDates = _checkIns.map(
          (checkIn) => DateTime(
        checkIn.createdAt.year,
        checkIn.createdAt.month,
        checkIn.createdAt.day,
      ),
    ).toSet();

    return List.generate(
      numberOfDays,
          (index) {
        final date = today.subtract(
          Duration(days: numberOfDays - 1 - index),
        );

        return checkInDates.contains(date);
      },
    );
  }

  List<String> _buildStreakLabels() {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    return List.generate(
      7,
          (index) {
        final date = today.subtract(
          Duration(days: 6 - index),
        );

        if (_selectedPeriod == 0) {
          const days = [
            'M',
            'T',
            'W',
            'T',
            'F',
            'S',
            'S',
          ];

          return days[date.weekday - 1];
        }

        if (_selectedPeriod == 1) {
          return '${date.day}';
        }

        return _monthName(date.month);
      },
    );
  }

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
    if (_checkIns.isEmpty) {
      return _insightsData[_selectedPeriod];
    }

    return _buildInsightsFromCheckIns();
  }

  @override
  void initState() {
    super.initState();

    _loadCheckIns();
  }

  Future<void> _loadCheckIns() async {
    try {
      final checkIns = await CheckInService.getCheckIns();

      if (!mounted) return;

      setState(() {
        _checkIns = checkIns;
        _isLoadingCheckIns = false;
        _checkInError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingCheckIns = false;
        _checkInError = error.toString();
      });
    }
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

          IconButton(
            onPressed: widget.onBackToHome,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(
                  color: AppColors.borderMint,
                ),
              ),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.navy,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // ------------------------------------------------------
          // TITLE
          // ------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Insights',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _isLoadingCheckIns
                      ? 'Loading check-ins...'
                      : _checkInError != null
                      ? 'ERROR: $_checkInError'
                      : '${_checkIns.length} check-in${_checkIns.length == 1 ? '' : 's'} recorded',
                  style: const TextStyle(
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
              positive: _getMetricChangeValue('mood') >= 0,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: _buildMetricCard(
              icon: Icons.bolt_outlined,
              title: 'Energy',
              value: data.energy.toStringAsFixed(1),
              change: _getMetricChange('energy'),
              positive: _getMetricChangeValue('energy') >= 0,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: _buildMetricCard(
              icon: Icons.bedtime_outlined,
              title: 'Sleep',
              value: data.sleep.toStringAsFixed(1),
              change: _getMetricChange('sleep'),
              positive: _getMetricChangeValue('sleep') >= 0,
            ),
          ),
        ],
      ),
    );
  }

  double _getMetricChangeValue(String type) {
    final now = DateTime.now();

    final DateTime startDate;

    switch (_selectedPeriod) {
      case 0:
        startDate = now.subtract(
          const Duration(days: 7),
        );
        break;

      case 1:
        startDate = now.subtract(
          const Duration(days: 30),
        );
        break;

      default:
        startDate = now.subtract(
          const Duration(days: 90),
        );
        break;
    }

    final periodCheckIns = _checkIns
        .where(
          (checkIn) =>
      !checkIn.createdAt.isBefore(startDate),
    )
        .toList()
      ..sort(
            (a, b) => a.createdAt.compareTo(b.createdAt),
      );

    if (periodCheckIns.length < 2) {
      return 0;
    }

    double firstValue;
    double lastValue;

    switch (type) {
      case 'mood':
        firstValue = _moodToValue(
          periodCheckIns.first.mood,
        );
        lastValue = _moodToValue(
          periodCheckIns.last.mood,
        );
        break;

      case 'energy':
        firstValue =
            periodCheckIns.first.energyLevel.toDouble();
        lastValue =
            periodCheckIns.last.energyLevel.toDouble();
        break;

      case 'sleep':
        firstValue =
            periodCheckIns.first.sleepQuality.toDouble();
        lastValue =
            periodCheckIns.last.sleepQuality.toDouble();
        break;

      default:
        return 0;
    }

    return lastValue - firstValue;
  }

  String _getMetricChange(String type) {
    final now = DateTime.now();

    final DateTime startDate;

    switch (_selectedPeriod) {
      case 0:
        startDate = now.subtract(
          const Duration(days: 7),
        );
        break;

      case 1:
        startDate = now.subtract(
          const Duration(days: 30),
        );
        break;

      default:
        startDate = now.subtract(
          const Duration(days: 90),
        );
        break;
    }

    final periodCheckIns = _checkIns
        .where(
          (checkIn) =>
      !checkIn.createdAt.isBefore(startDate),
    )
        .toList()
      ..sort(
            (a, b) => a.createdAt.compareTo(b.createdAt),
      );

    if (periodCheckIns.length < 2) {
      return '+0.0';
    }

    double firstValue;
    double lastValue;

    switch (type) {
      case 'mood':
        firstValue = _moodToValue(
          periodCheckIns.first.mood,
        );
        lastValue = _moodToValue(
          periodCheckIns.last.mood,
        );
        break;

      case 'energy':
        firstValue =
            periodCheckIns.first.energyLevel.toDouble();
        lastValue =
            periodCheckIns.last.energyLevel.toDouble();
        break;

      case 'sleep':
        firstValue =
            periodCheckIns.first.sleepQuality.toDouble();
        lastValue =
            periodCheckIns.last.sleepQuality.toDouble();
        break;

      default:
        return '+0.0';
    }

    final change = lastValue - firstValue;

    if (change > 0) {
      return '+${change.toStringAsFixed(1)}';
    }

    return change.toStringAsFixed(1);
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
      ((value - 1) / 9).clamp(0.0, 1.0);

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