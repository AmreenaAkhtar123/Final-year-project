import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class WeeklyWellbeingScreen extends StatefulWidget {
  const WeeklyWellbeingScreen({super.key});

  @override
  State<WeeklyWellbeingScreen> createState() =>
      _WeeklyWellbeingScreenState();
}

class _WeeklyWellbeingScreenState
    extends State<WeeklyWellbeingScreen> {
  int _selectedDay = 6;

  final List<Map<String, dynamic>> _weekData = [
    {
      'day': 'Monday',
      'short': 'M',
      'score': 5.2,
      'mood': 'Calm',
      'emoji': '😌',
      'intensity': 5,
      'energy': 6,
      'stress': 6,
      'sleep': 6,
      'checkIn': true,
    },
    {
      'day': 'Tuesday',
      'short': 'T',
      'score': 6.8,
      'mood': 'Happy',
      'emoji': '😊',
      'intensity': 7,
      'energy': 7,
      'stress': 4,
      'sleep': 7,
      'checkIn': true,
    },
    {
      'day': 'Wednesday',
      'short': 'W',
      'score': 4.5,
      'mood': 'Anxious',
      'emoji': '😟',
      'intensity': 4,
      'energy': 5,
      'stress': 8,
      'sleep': 5,
      'checkIn': true,
    },
    {
      'day': 'Thursday',
      'short': 'T',
      'score': 7.8,
      'mood': 'Good',
      'emoji': '🙂',
      'intensity': 8,
      'energy': 8,
      'stress': 3,
      'sleep': 8,
      'checkIn': true,
    },
    {
      'day': 'Friday',
      'short': 'F',
      'score': 7.2,
      'mood': 'Calm',
      'emoji': '😌',
      'intensity': 7,
      'energy': 7,
      'stress': 4,
      'sleep': 7,
      'checkIn': true,
    },
    {
      'day': 'Saturday',
      'short': 'S',
      'score': 8.6,
      'mood': 'Happy',
      'emoji': '😊',
      'intensity': 9,
      'energy': 9,
      'stress': 2,
      'sleep': 9,
      'checkIn': true,
    },
    {
      'day': 'Sunday',
      'short': 'S',
      'score': 7.2,
      'mood': 'Good',
      'emoji': '🙂',
      'intensity': 7,
      'energy': 7,
      'stress': 4,
      'sleep': 8,
      'checkIn': true,
    },
  ];

  double get _weeklyAverage {
    final total = _weekData.fold<double>(
      0,
          (sum, item) => sum + (item['score'] as double),
    );

    return total / _weekData.length;
  }

  double get _averageEnergy {
    final total = _weekData.fold<double>(
      0,
          (sum, item) => sum + (item['energy'] as int),
    );

    return total / _weekData.length;
  }

  double get _averageStress {
    final total = _weekData.fold<double>(
      0,
          (sum, item) => sum + (item['stress'] as int),
    );

    return total / _weekData.length;
  }

  double get _averageSleep {
    final total = _weekData.fold<double>(
      0,
          (sum, item) => sum + (item['sleep'] as int),
    );

    return total / _weekData.length;
  }

  int get _checkIns {
    return _weekData
        .where((item) => item['checkIn'] == true)
        .length;
  }

  Map<String, dynamic> get _bestDay {
    return _weekData.reduce(
          (current, item) =>
      item['score'] > current['score'] ? item : current,
    );
  }

  Map<String, dynamic> get _lowestDay {
    return _weekData.reduce(
          (current, item) =>
      item['score'] < current['score'] ? item : current,
    );
  }

  String get _weeklyLabel {
    if (_weeklyAverage >= 8) {
      return 'Excellent week';
    }

    if (_weeklyAverage >= 7) {
      return 'Good week';
    }

    if (_weeklyAverage >= 5) {
      return 'Fair week';
    }

    return 'Needs attention';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  35,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(),

                    const SizedBox(height: 20),

                    _buildWeekComparison(),

                    const SizedBox(height: 20),

                    _buildTrendCard(),

                    const SizedBox(height: 20),

                    _buildSelectedDay(),

                    const SizedBox(height: 20),

                    _buildPatterns(),

                    const SizedBox(height: 20),

                    _buildWeeklyInsight(),

                    const SizedBox(height: 20),

                    _buildConsistency(),

                    const SizedBox(height: 20),

                    _buildAchievements(),

                    const SizedBox(height: 20),

                    _buildScoreExplanation(),

                    const SizedBox(height: 20),

                    _buildDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          6,
        ),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.borderMint,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.navy,
                    size: 15,
                  ),
                ),
              ),
            ),

            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Weekly Wellbeing',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Your wellbeing at a glance',
                      style: TextStyle(
                        color: Color(0xFF71808C),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '7 DAYS',
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // OVERVIEW
  // =========================================================

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.navy,
            const Color(0xFF2B4657),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 92,
                      height: 92,
                      child: CircularProgressIndicator(
                        value: _weeklyAverage / 10,
                        strokeWidth: 8,
                        backgroundColor:
                        Colors.white.withValues(alpha: 0.10),
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(
                          AppColors.mint,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          _weeklyAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '/ 10',
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: 0.55,
                            ),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 19),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WEEKLY WELLBEING',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _weeklyLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Your overall wellbeing based on this week\'s check-ins.',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.62,
                        ),
                        fontSize: 10.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.mint,
                  size: 17,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    '$_checkIns of 7 daily check-ins completed',
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: 0.78,
                      ),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Text(
                  '100%',
                  style: TextStyle(
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
    );
  }

  // =========================================================
  // WEEK COMPARISON
  // =========================================================

  Widget _buildWeekComparison() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'This week vs last week',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.mint,
                      size: 14,
                    ),
                    SizedBox(width: 3),
                    Text(
                      '+11.3%',
                      style: TextStyle(
                        color: AppColors.mint,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildComparisonValue(
                  'This week',
                  _weeklyAverage.toStringAsFixed(1),
                  true,
                ),
              ),

              Container(
                width: 1,
                height: 45,
                color: AppColors.borderMint,
              ),

              Expanded(
                child: _buildComparisonValue(
                  'Last week',
                  '6.2',
                  false,
                ),
              ),

              Container(
                width: 1,
                height: 45,
                color: AppColors.borderMint,
              ),

              Expanded(
                child: _buildComparisonValue(
                  'Difference',
                  '+0.7',
                  true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonValue(
      String title,
      String value,
      bool highlighted,
      ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.43),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          value,
          style: TextStyle(
            color: highlighted
                ? AppColors.mint
                : AppColors.navy,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // TREND
  // =========================================================

  Widget _buildTrendCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wellbeing trend',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Daily wellbeing score',
                      style: TextStyle(
                        color: Color(0xFF71808C),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              _buildLegend(
                AppColors.mint,
                'Score',
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                _buildYAxis(),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: List.generate(
                            _weekData.length,
                                (index) {
                              return _buildTrendBar(index);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                        children: _weekData.map(
                              (item) {
                            return SizedBox(
                              width: 22,
                              child: Text(
                                item['short'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.navy
                                      .withValues(alpha: 0.45),
                                  fontSize: 9,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Tap a bar to explore that day.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.40),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYAxis() {
    return SizedBox(
      height: 155,
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            '10',
            style: TextStyle(
              color: Color(0xFF9AA5AC),
              fontSize: 8,
            ),
          ),
          Text(
            '7.5',
            style: TextStyle(
              color: Color(0xFF9AA5AC),
              fontSize: 8,
            ),
          ),
          Text(
            '5',
            style: TextStyle(
              color: Color(0xFF9AA5AC),
              fontSize: 8,
            ),
          ),
          Text(
            '2.5',
            style: TextStyle(
              color: Color(0xFF9AA5AC),
              fontSize: 8,
            ),
          ),
          Text(
            '0',
            style: TextStyle(
              color: Color(0xFF9AA5AC),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBar(int index) {
    final item = _weekData[index];
    final score = item['score'] as double;
    final selected = index == _selectedDay;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = index;
        });
      },
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.end,
        children: [
          if (selected)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                score.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: selected ? 25 : 19,
            height: score * 13,
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                colors: [
                  AppColors.mint,
                  Color(0xFF8AC9AE),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
                  : null,
              color: selected
                  ? null
                  : AppColors.lightMint,
              borderRadius: BorderRadius.circular(9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
      Color color,
      String label,
      ) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 5),

        Text(
          label,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.45),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // SELECTED DAY
  // =========================================================

  Widget _buildSelectedDay() {
    final item = _weekData[_selectedDay];

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    item['emoji'],
                    style: const TextStyle(
                      fontSize: 28,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['day'],
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Daily wellbeing snapshot',
                      style: TextStyle(
                        color: AppColors.navy
                            .withValues(alpha: 0.43),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Text(
                    item['score'].toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.mint,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '/ 10',
                    style: TextStyle(
                      color: AppColors.navy
                          .withValues(alpha: 0.38),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  Icons.mood_rounded,
                  'Mood',
                  item['mood'],
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _buildMetricTile(
                  Icons.bolt_rounded,
                  'Energy',
                  '${item['energy']}/10',
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  Icons.psychology_alt_rounded,
                  'Stress',
                  '${item['stress']}/10',
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _buildMetricTile(
                  Icons.bedtime_rounded,
                  'Sleep',
                  '${item['sleep']}/10',
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.mint,
                  size: 16,
                ),

                const SizedBox(width: 8),

                const Expanded(
                  child: Text(
                    'Daily check-in completed',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Text(
                  'Complete',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: AppColors.mint,
              size: 16,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.navy
                        .withValues(alpha: 0.40),
                    fontSize: 8,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PATTERNS
  // =========================================================

  Widget _buildPatterns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your wellbeing patterns',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'A quick look at your main wellbeing signals.',
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.43),
            fontSize: 10,
          ),
        ),

        const SizedBox(height: 13),

        Row(
          children: [
            Expanded(
              child: _buildPatternCard(
                Icons.bolt_rounded,
                'Energy',
                _averageEnergy.toStringAsFixed(1),
                'out of 10',
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildPatternCard(
                Icons.psychology_alt_rounded,
                'Stress',
                _averageStress.toStringAsFixed(1),
                'out of 10',
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildPatternCard(
                Icons.bedtime_rounded,
                'Sleep',
                _averageSleep.toStringAsFixed(1),
                'out of 10',
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildPatternCard(
                Icons.emoji_emotions_rounded,
                'Best day',
                _bestDay['day'].substring(0, 3),
                '${_bestDay['score'].toStringAsFixed(1)}/10',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatternCard(
      IconData icon,
      String title,
      String value,
      String detail,
      ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.mint,
            size: 20,
          ),

          const SizedBox(height: 11),

          Text(
            title,
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.43),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            detail,
            style: const TextStyle(
              color: AppColors.mint,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // WEEKLY INSIGHT
  // =========================================================

  Widget _buildWeeklyInsight() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
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
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.mint,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'WEEKLY INSIGHT',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  'Your wellbeing improved toward the weekend, with your strongest score on Saturday. Wednesday showed the lowest score alongside higher stress and lower sleep.',
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.72),
                    fontSize: 10.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.mint,
                      size: 14,
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        'Consider protecting the routines that supported your stronger days.',
                        style: TextStyle(
                          color: AppColors.navy
                              .withValues(alpha: 0.58),
                          fontSize: 9,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CONSISTENCY
  // =========================================================

  Widget _buildConsistency() {
    return _buildCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Check-in consistency',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const Text(
                '7 / 7',
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            'You checked in every day this week.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.43),
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 17),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 1,
              minHeight: 9,
              backgroundColor: AppColors.lightMint,
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
                  (index) {
                return Column(
                  children: [
                    Container(
                      width: 29,
                      height: 29,
                      decoration: const BoxDecoration(
                        color: AppColors.mint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _weekData[index]['short'],
                      style: TextStyle(
                        color: AppColors.navy
                            .withValues(alpha: 0.40),
                        fontSize: 8,
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
    );
  }

  // =========================================================
  // ACHIEVEMENTS
  // =========================================================

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'This week\'s achievements',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 13),

        _buildAchievement(
          Icons.calendar_month_rounded,
          '7-day check-in streak',
          'You stayed consistent all week.',
        ),

        const SizedBox(height: 9),

        _buildAchievement(
          Icons.trending_up_rounded,
          'Weekend improvement',
          'Your wellbeing scores increased toward the weekend.',
        ),

        const SizedBox(height: 9),

        _buildAchievement(
          Icons.self_improvement_rounded,
          'Mindful tracking',
          'You completed your daily wellbeing check-ins.',
        ),
      ],
    );
  }

  Widget _buildAchievement(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.mint,
              size: 19,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.navy
                        .withValues(alpha: 0.43),
                    fontSize: 9,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.mint,
            size: 19,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SCORE EXPLANATION
  // =========================================================

  Widget _buildScoreExplanation() {
    return _buildCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
                child: const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.mint,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'How your score works',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'Your weekly wellbeing score is a demo representation for the current UI. In the final version, MindMate can calculate it from your recorded wellbeing signals.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.58),
              fontSize: 10,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _buildScoreTag('Mood'),
              _buildScoreTag('Energy'),
              _buildScoreTag('Sleep'),
              _buildScoreTag('Stress'),
              _buildScoreTag('Check-ins'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.mint,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // =========================================================
  // DISCLAIMER
  // =========================================================

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.navy.withValues(alpha: 0.35),
            size: 16,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              'Weekly wellbeing insights are intended for self-reflection and do not provide a medical diagnosis.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.42),
                fontSize: 9,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SHARED CARD
  // =========================================================

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: child,
    );
  }
}