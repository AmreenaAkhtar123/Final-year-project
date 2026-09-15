import 'dart:math' as math;

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
                'See how your mood has changed',
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset(
              'assets/images/logo1.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Insights',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Understand your wellbeing journey',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              icon: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.navy,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
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
                  onTap: () {
                    setState(() {
                      _selectedPeriod = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: selected
                          ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _periods[index],
                      style: TextStyle(
                        color: selected
                            ? AppColors.navy
                            : Colors.black54,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
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

  Widget _buildOverviewCard() {
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
                        color: AppColors.mint.withValues(alpha: 0.18),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: AppColors.mint,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '+8%',
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
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '7.4',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        '/ 10',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.48),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  'Your wellbeing score is looking positive.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: 0.74,
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.10),
                    valueColor: const AlwaysStoppedAnimation(
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

  Widget _buildSectionTitle(
      String title,
      String subtitle,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
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

  Widget _buildMoodChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 245,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
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
                const Text(
                  'Average / 10',
                  style: TextStyle(
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
                painter: _MoodChartPainter(),
                child: const SizedBox.expand(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('Mon'),
                Text('Tue'),
                Text('Wed'),
                Text('Thu'),
                Text('Fri'),
                Text('Sat'),
                Text('Sun'),
              ]
                  .map(
                    (text) => Text(
                  text.data!,
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  .toList(),
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

  Widget _buildWellbeingGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              icon: Icons.favorite_outline_rounded,
              title: 'Mood',
              value: '7.4',
              change: '+0.6',
              positive: true,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: _buildMetricCard(
              icon: Icons.bolt_outlined,
              title: 'Energy',
              value: '6.8',
              change: '+0.3',
              positive: true,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: _buildMetricCard(
              icon: Icons.bedtime_outlined,
              title: 'Sleep',
              value: '7.1',
              change: '+0.8',
              positive: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String change,
    required bool positive,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 13),
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

  Widget _buildEmotionCard() {
    final emotions = [
      {
        'name': 'Calm',
        'value': 0.82,
        'icon': Icons.spa_outlined,
      },
      {
        'name': 'Happy',
        'value': 0.68,
        'icon': Icons.sentiment_satisfied_alt_outlined,
      },
      {
        'name': 'Motivated',
        'value': 0.56,
        'icon': Icons.rocket_launch_outlined,
      },
      {
        'name': 'Anxious',
        'value': 0.38,
        'icon': Icons.psychology_outlined,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          children: emotions.map((emotion) {
            final value = emotion['value'] as double;
            final isNegative = emotion['name'] == 'Anxious';

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: isNegative
                          ? const Color(0xFFFFF4F0)
                          : AppColors.lightMint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      emotion['icon'] as IconData,
                      size: 17,
                      color: isNegative
                          ? const Color(0xFFE68A69)
                          : AppColors.mint,
                    ),
                  ),
                  const SizedBox(width: 11),
                  SizedBox(
                    width: 68,
                    child: Text(
                      emotion['name'] as String,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 7,
                        backgroundColor: AppColors.lightMint,
                        valueColor: AlwaysStoppedAnimation(
                          isNegative
                              ? const Color(0xFFE6A18A)
                              : AppColors.mint,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    '${(value * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInsightCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.mint,
                size: 21,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You’re finding your balance',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Your mood has been more positive on days when your energy and sleep are higher. Keep giving yourself time to rest and recharge.',
                    style: TextStyle(
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

  Widget _buildStreakCard() {
    final days = [
      true,
      true,
      true,
      true,
      false,
      true,
      true,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_outlined,
                    color: AppColors.mint,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '6 day streak',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Keep checking in to build your streak',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '6 / 7',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                7,
                    (index) {
                  return Column(
                    children: [
                      Container(
                        width: 29,
                        height: 29,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: days[index]
                              ? AppColors.mint
                              : AppColors.lightMint,
                        ),
                        child: days[index]
                            ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          'M',
                          'T',
                          'W',
                          'T',
                          'F',
                          'S',
                          'S',
                        ][index],
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 9,
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

class _MoodChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
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
      final y = size.height * i / horizontalLines;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final moodValues = [5.8, 6.7, 6.2, 7.5, 7.1, 8.0, 8.3];
    final energyValues = [5.2, 5.9, 6.6, 6.1, 6.9, 7.2, 7.4];

    Offset pointFor(
        int index,
        double value,
        ) {
      final x = index * size.width / (moodValues.length - 1);
      final y = size.height -
          ((value - 4) / 6) * size.height;

      return Offset(x, y);
    }

    final moodPath = Path();
    final energyPath = Path();
    final fillPath = Path();

    for (int i = 0; i < moodValues.length; i++) {
      final moodPoint = pointFor(i, moodValues[i]);
      final energyPoint = pointFor(i, energyValues[i]);

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

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, moodFillPaint);
    canvas.drawPath(moodPath, moodPaint);
    canvas.drawPath(energyPath, energyPaint);

    for (int i = 0; i < moodValues.length; i++) {
      final moodPoint = pointFor(i, moodValues[i]);

      canvas.drawCircle(
        moodPoint,
        4,
        Paint()..color = AppColors.mint,
      );

      canvas.drawCircle(
        moodPoint,
        2,
        Paint()..color = Colors.white,
      );
    }

    // Subtle chart baseline.
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      gridPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}