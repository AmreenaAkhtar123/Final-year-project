import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/services/check_in_service.dart';
import '../models/check_in.dart';

class WeeklyWellbeingScreen extends StatefulWidget {
  const WeeklyWellbeingScreen({super.key});

  @override
  State<WeeklyWellbeingScreen> createState() =>
      _WeeklyWellbeingScreenState();
}

class _WeeklyWellbeingScreenState
    extends State<WeeklyWellbeingScreen> {
  int _selectedDay = 0;

  List<Map<String, dynamic>> _weekData = [];

  List<CheckIn> _allCheckIns = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  // =========================================================
  // DATA HELPERS
  // =========================================================

  String _moodEmoji(String mood) {
    switch (mood) {
      case 'Low':
        return '😔';
      case 'Okay':
        return '😐';
      case 'Neutral':
        return '😶';
      case 'Good':
        return '🙂';
      case 'Great':
        return '😊';
      default:
        return '🙂';
    }
  }

  double _moodToValue(String mood) {
    return {
      'Low': 2.0,
      'Okay': 4.0,
      'Neutral': 5.0,
      'Good': 7.0,
      'Great': 9.0,
    }[mood] ??
        5.0;
  }

  double _checkInScore(CheckIn checkIn) {
    final moodValue = _moodToValue(checkIn.mood);

    return (
        moodValue +
            checkIn.energyLevel +
            checkIn.sleepQuality
    ) /
        3;
  }

  DateTime _dateOnly(DateTime date) {
    final local = date.toLocal();

    return DateTime(
      local.year,
      local.month,
      local.day,
    );
  }

  DateTime _startOfCurrentWeek() {
    final today = _dateOnly(DateTime.now());

    return today.subtract(
      Duration(days: today.weekday - 1),
    );
  }

  String _dayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return names[weekday - 1];
  }

  String _shortDayName(int weekday) {
    const names = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    return names[weekday - 1];
  }

  // =========================================================
  // LOAD WEEKLY DATA
  // =========================================================

  Future<void> _loadWeeklyData() async {
    try {
      final checkIns = await CheckInService.getCheckIns();

      if (!mounted) return;

      final startOfWeek = _startOfCurrentWeek();

      final weekData = List.generate(
        7,
            (index) {
          final day = startOfWeek.add(
            Duration(days: index),
          );

          final dayCheckIns = checkIns.where((checkIn) {
            final checkInDate = _dateOnly(
              checkIn.createdAt,
            );

            return checkInDate == day;
          }).toList();

          if (dayCheckIns.isEmpty) {
            return {
              'day': _dayName(day.weekday),
              'short': _shortDayName(day.weekday),
              'score': 0.0,
              'mood': '--',
              'emoji': '○',
              'intensity': 0,
              'energy': 0,
              'sleep': 0,
              'checkIn': false,
            };
          }

          final averageScore =
              dayCheckIns
                  .map(_checkInScore)
                  .reduce((a, b) => a + b) /
                  dayCheckIns.length;

          final averageIntensity =
              dayCheckIns
                  .map((checkIn) => checkIn.moodIntensity)
                  .reduce((a, b) => a + b) /
                  dayCheckIns.length;

          final averageEnergy =
              dayCheckIns
                  .map((checkIn) => checkIn.energyLevel)
                  .reduce((a, b) => a + b) /
                  dayCheckIns.length;

          final averageSleep =
              dayCheckIns
                  .map((checkIn) => checkIn.sleepQuality)
                  .reduce((a, b) => a + b) /
                  dayCheckIns.length;

          final latestCheckIn = dayCheckIns.first;

          return {
            'day': _dayName(day.weekday),
            'short': _shortDayName(day.weekday),
            'score': averageScore,
            'mood': latestCheckIn.mood,
            'emoji': _moodEmoji(latestCheckIn.mood),
            'intensity': averageIntensity.round(),
            'energy': averageEnergy.round(),
            'sleep': averageSleep.round(),
            'checkIn': true,
          };
        },
      );

      int selectedDay = DateTime.now().weekday - 1;

      if (selectedDay < 0 || selectedDay > 6) {
        selectedDay = 0;
      }

      setState(() {
        _allCheckIns = checkIns;
        _weekData = weekData;
        _selectedDay = selectedDay;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _allCheckIns = [];
        _weekData = _buildEmptyWeek();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _buildEmptyWeek() {
    return List.generate(
      7,
          (index) {
        return {
          'day': _dayName(index + 1),
          'short': _shortDayName(index + 1),
          'score': 0.0,
          'mood': '--',
          'emoji': '○',
          'intensity': 0,
          'energy': 0,
          'sleep': 0,
          'checkIn': false,
        };
      },
    );
  }

  // =========================================================
  // CALCULATED VALUES
  // =========================================================

  double get _weeklyAverage {
    final completedDays = _weekData.where(
          (item) => item['checkIn'] == true,
    );

    if (completedDays.isEmpty) {
      return 0;
    }

    final total = completedDays.fold<double>(
      0,
          (sum, item) => sum + (item['score'] as double),
    );

    return total / completedDays.length;
  }

  double get _averageIntensity {
    final completedDays = _weekData.where(
          (item) => item['checkIn'] == true,
    );

    if (completedDays.isEmpty) {
      return 0;
    }

    final total = completedDays.fold<double>(
      0,
          (sum, item) => sum + (item['intensity'] as int),
    );

    return total / completedDays.length;
  }

  double get _averageEnergy {
    final completedDays = _weekData.where(
          (item) => item['checkIn'] == true,
    );

    if (completedDays.isEmpty) {
      return 0;
    }

    final total = completedDays.fold<double>(
      0,
          (sum, item) => sum + (item['energy'] as int),
    );

    return total / completedDays.length;
  }

  double get _averageSleep {
    final completedDays = _weekData.where(
          (item) => item['checkIn'] == true,
    );

    if (completedDays.isEmpty) {
      return 0;
    }

    final total = completedDays.fold<double>(
      0,
          (sum, item) => sum + (item['sleep'] as int),
    );

    return total / completedDays.length;
  }

  int get _checkIns {
    return _weekData.where(
          (item) => item['checkIn'] == true,
    ).length;
  }

  Map<String, dynamic>? get _bestDay {
    final completedDays = _weekData
        .where(
          (item) => item['checkIn'] == true,
    )
        .toList();

    if (completedDays.isEmpty) {
      return null;
    }

    Map<String, dynamic> best = completedDays.first;

    for (final item in completedDays.skip(1)) {
      final itemScore =
      (item['score'] as num).toDouble();

      final bestScore =
      (best['score'] as num).toDouble();

      if (itemScore > bestScore) {
        best = item;
      }
    }

    return best;
  }

  Map<String, dynamic>? get _lowestDay {
    final completedDays = _weekData
        .where(
          (item) => item['checkIn'] == true,
    )
        .toList();

    if (completedDays.isEmpty) {
      return null;
    }

    Map<String, dynamic> lowest = completedDays.first;

    for (final item in completedDays.skip(1)) {
      final itemScore =
      (item['score'] as num).toDouble();

      final lowestScore =
      (lowest['score'] as num).toDouble();

      if (itemScore < lowestScore) {
        lowest = item;
      }
    }

    return lowest;
  }

  double _averageForWeek(DateTime start) {
    final end = start.add(
      const Duration(days: 7),
    );

    final checkIns = _allCheckIns.where((checkIn) {
      final date = _dateOnly(checkIn.createdAt);

      return !date.isBefore(start) &&
          date.isBefore(end);
    }).toList();

    if (checkIns.isEmpty) {
      return 0;
    }

    final total = checkIns.fold<double>(
      0,
          (sum, checkIn) =>
      sum + _checkInScore(checkIn),
    );

    return total / checkIns.length;
  }

  double get _lastWeekAverage {
    final currentWeekStart = _startOfCurrentWeek();

    final lastWeekStart = currentWeekStart.subtract(
      const Duration(days: 7),
    );

    return _averageForWeek(lastWeekStart);
  }

  double get _weekDifference {
    return _weeklyAverage - _lastWeekAverage;
  }

  double get _weekPercentageChange {
    if (_lastWeekAverage == 0) {
      return 0;
    }

    return (_weekDifference / _lastWeekAverage) * 100;
  }

  String get _weeklyLabel {
    if (_checkIns == 0) {
      return 'No data yet';
    }

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

  // =========================================================
  // MAIN BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.mint,
                ),
              )
                  : SingleChildScrollView(
                physics:
                const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  35,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                    borderRadius:
                    BorderRadius.circular(10),
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
              padding:
              const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius:
                BorderRadius.circular(10),
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
        gradient: const LinearGradient(
          colors: [
            AppColors.navy,
            Color(0xFF2B4657),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color:
            AppColors.navy.withValues(alpha: 0.10),
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
                        value:
                        (_weeklyAverage / 10)
                            .clamp(0.0, 1.0),
                        strokeWidth: 8,
                        backgroundColor:
                        Colors.white.withValues(
                          alpha: 0.10,
                        ),
                        valueColor:
                        const AlwaysStoppedAnimation<
                            Color>(
                          AppColors.mint,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Text(
                          _weeklyAverage
                              .toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '/ 10',
                          style: TextStyle(
                            color:
                            Colors.white.withValues(
                              alpha: 0.55,
                            ),
                            fontSize: 9,
                            fontWeight:
                            FontWeight.w600,
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
                        color:
                        Colors.white.withValues(
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
            padding:
            const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color:
              Colors.white.withValues(alpha: 0.08),
              borderRadius:
              BorderRadius.circular(15),
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
                      color:
                      Colors.white.withValues(
                        alpha: 0.78,
                      ),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Text(
                  '${(_checkIns / 7 * 100).round()}%',
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
    );
  }

  // =========================================================
  // WEEK COMPARISON
  // =========================================================

  Widget _buildWeekComparison() {
    return _buildCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius:
                  BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _weekDifference >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: AppColors.mint,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _lastWeekAverage == 0
                          ? '--'
                          : '${_weekPercentageChange >= 0 ? '+' : ''}${_weekPercentageChange.toStringAsFixed(1)}%',
                      style: const TextStyle(
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
                  _weeklyAverage
                      .toStringAsFixed(1),
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
                  _lastWeekAverage == 0
                      ? '--'
                      : _lastWeekAverage
                      .toStringAsFixed(1),
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
                  _lastWeekAverage == 0
                      ? '--'
                      : '${_weekDifference >= 0 ? '+' : ''}${_weekDifference.toStringAsFixed(1)}',
                  _weekDifference >= 0,
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
            color:
            AppColors.navy.withValues(
              alpha: 0.43,
            ),
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
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
                              return _buildTrendBar(
                                index,
                              );
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
                                textAlign:
                                TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.navy
                                      .withValues(
                                    alpha: 0.45,
                                  ),
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
              color:
              AppColors.navy.withValues(
                alpha: 0.40,
              ),
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
    final hasCheckIn = item['checkIn'] == true;
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
          if (selected && hasCheckIn)
            Container(
              margin:
              const EdgeInsets.only(
                bottom: 6,
              ),
              padding:
              const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius:
                BorderRadius.circular(6),
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
            duration:
            const Duration(milliseconds: 250),
            width: selected ? 25 : 19,
            height: hasCheckIn
                ? (score * 13).clamp(4.0, 155.0)
                : 4,
            decoration: BoxDecoration(
              gradient: selected && hasCheckIn
                  ? const LinearGradient(
                colors: [
                  AppColors.mint,
                  Color(0xFF8AC9AE),
                ],
                begin:
                Alignment.topCenter,
                end:
                Alignment.bottomCenter,
              )
                  : null,
              color: selected && hasCheckIn
                  ? null
                  : hasCheckIn
                  ? AppColors.lightMint
                  : AppColors.borderMint,
              borderRadius:
              BorderRadius.circular(9),
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
            color:
            AppColors.navy.withValues(
              alpha: 0.45,
            ),
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
    if (_weekData.isEmpty) {
      return const SizedBox.shrink();
    }

    final item = _weekData[_selectedDay];
    final hasCheckIn = item['checkIn'] == true;

    return _buildCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    item['emoji'] as String,
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
                      item['day'] as String,
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
                        color:
                        AppColors.navy.withValues(
                          alpha: 0.43,
                        ),
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
                    hasCheckIn
                        ? (item['score'] as double)
                        .toStringAsFixed(1)
                        : '--',
                    style: const TextStyle(
                      color: AppColors.mint,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  Text(
                    '/ 10',
                    style: TextStyle(
                      color:
                      AppColors.navy.withValues(
                        alpha: 0.38,
                      ),
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
                  hasCheckIn
                      ? item['mood'] as String
                      : '--',
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _buildMetricTile(
                  Icons.bolt_rounded,
                  'Energy',
                  hasCheckIn
                      ? '${item['energy']}/10'
                      : '--',
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  Icons.tune_rounded,
                  'Intensity',
                  hasCheckIn
                      ? '${item['intensity']}/10'
                      : '--',
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _buildMetricTile(
                  Icons.bedtime_rounded,
                  'Sleep',
                  hasCheckIn
                      ? '${item['sleep']}/10'
                      : '--',
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Icon(
                  hasCheckIn
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  color: AppColors.mint,
                  size: 16,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    hasCheckIn
                        ? 'Daily check-in completed'
                        : 'No check-in for this day',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 10,
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

  Widget _buildMetricTile(
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius:
        BorderRadius.circular(14),
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
              borderRadius:
              BorderRadius.circular(9),
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
                    color:
                    AppColors.navy.withValues(
                      alpha: 0.40,
                    ),
                    fontSize: 8,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  overflow:
                  TextOverflow.ellipsis,
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
    final hasData = _checkIns > 0;

    return _buildCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Your weekly patterns',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            hasData
                ? 'Based on your completed check-ins'
                : 'Patterns will appear after your check-ins',
            style: const TextStyle(
              color: Color(0xFF71808C),
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _buildPatternCard(
                  Icons.sentiment_satisfied_alt_rounded,
                  'Mood',
                  hasData
                      ? _averageIntensity
                      .toStringAsFixed(1)
                      : '--',
                  'out of 10',
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _buildPatternCard(
                  Icons.bolt_rounded,
                  'Energy',
                  hasData
                      ? _averageEnergy
                      .toStringAsFixed(1)
                      : '--',
                  'out of 10',
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Expanded(
                child: _buildPatternCard(
                  Icons.bedtime_rounded,
                  'Sleep',
                  hasData
                      ? _averageSleep
                      .toStringAsFixed(1)
                      : '--',
                  'out of 10',
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _buildPatternCard(
                  Icons.calendar_today_rounded,
                  'Check-ins',
                  '$_checkIns',
                  'of 7 days',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(
      IconData icon,
      String title,
      String value,
      String subtitle,
      ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius:
        BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.mint,
              size: 17,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color:
                    AppColors.navy.withValues(
                      alpha: 0.45,
                    ),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                Text(
                  subtitle,
                  style: TextStyle(
                    color:
                    AppColors.navy.withValues(
                      alpha: 0.38,
                    ),
                    fontSize: 7.5,
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
  // WEEKLY INSIGHT
  // =========================================================

  Widget _buildWeeklyInsight() {
    final bestDay = _bestDay;
    final lowestDay = _lowestDay;

    String title;
    String message;
    IconData icon;

    if (_checkIns == 0) {
      title = 'Start building your weekly picture';
      message =
      'Complete daily check-ins to see patterns and changes in your wellbeing over time.';
      icon = Icons.insights_rounded;
    } else if (_checkIns == 1) {
      title = 'One check-in recorded';
      message =
      'Keep checking in throughout the week to build a more useful picture of your wellbeing.';
      icon = Icons.auto_graph_rounded;
    } else {
      if (bestDay != null && lowestDay != null) {
        final bestScore =
        (bestDay['score'] as num).toDouble();

        final lowestScore =
        (lowestDay['score'] as num).toDouble();

        final bestDayName =
        bestDay['day'] as String;

        final lowestDayName =
        lowestDay['day'] as String;

        if ((bestScore - lowestScore).abs() < 0.5) {
          title = 'Your week looks fairly steady';
          message =
          'Your wellbeing scores stayed relatively consistent across the days you checked in.';
          icon = Icons.balance_rounded;
        } else {
          title = '$bestDayName was your strongest day';
          message =
          'Your wellbeing score was ${bestScore.toStringAsFixed(1)} on $bestDayName and ${lowestScore.toStringAsFixed(1)} on $lowestDayName. These patterns can help you reflect on what may have influenced different days.';
          icon = Icons.insights_rounded;
        }
      } else {
        title = 'Your weekly picture is taking shape';
        message =
        'Keep checking in to build a clearer picture of your wellbeing throughout the week.';
        icon = Icons.auto_graph_rounded;
      }
    }

    return _buildCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly insight',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.navy.withValues(
                      alpha: 0.55,
                    ),
                    fontSize: 10,
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
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check-in consistency',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your activity across the current week',
                      style: TextStyle(
                        color: Color(0xFF71808C),
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$_checkIns/7',
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 18,
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
              7,
                  (index) {
                final completed =
                    _weekData[index]['checkIn'] ==
                        true;

                return Column(
                  children: [
                    Container(
                      width: 29,
                      height: 29,
                      decoration: BoxDecoration(
                        color: completed
                            ? AppColors.mint
                            : AppColors.lightMint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        completed
                            ? Icons.check_rounded
                            : Icons.remove_rounded,
                        color: completed
                            ? Colors.white
                            : AppColors.navy
                            .withValues(
                          alpha: 0.30,
                        ),
                        size: 15,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _weekData[index]['short'],
                      style: TextStyle(
                        color: AppColors.navy
                            .withValues(
                          alpha: 0.40,
                        ),
                        fontSize: 8,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Text(
              _checkIns == 0
                  ? 'No check-ins recorded this week.'
                  : 'You completed $_checkIns of 7 possible daily check-ins this week.',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
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
    final hasThree =
        _checkIns >= 3;
    final hasFive =
        _checkIns >= 5;
    final hasSeven =
        _checkIns == 7;

    return _buildCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly milestones',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Based on your check-in activity',
            style: TextStyle(
              color: Color(0xFF71808C),
              fontSize: 9.5,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildAchievement(
                  Icons.flag_rounded,
                  '3 days',
                  'Started',
                  hasThree,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildAchievement(
                  Icons.local_fire_department_rounded,
                  '5 days',
                  'Consistent',
                  hasFive,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _buildAchievement(
                  Icons.star_rounded,
                  '7 days',
                  'Full week',
                  hasSeven,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement(
      IconData icon,
      String title,
      String subtitle,
      bool unlocked,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.lightMint
            : const Color(0xFFF8FAF9),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: unlocked
              ? AppColors.mint.withValues(
            alpha: 0.35,
          )
              : AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: unlocked
                ? AppColors.mint
                : AppColors.navy.withValues(
              alpha: 0.25,
            ),
            size: 21,
          ),

          const SizedBox(height: 7),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: unlocked
                  ? AppColors.navy
                  : AppColors.navy.withValues(
                alpha: 0.40,
              ),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            unlocked
                ? subtitle
                : 'Not yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy.withValues(
                alpha: 0.40,
              ),
              fontSize: 7.5,
              fontWeight: FontWeight.w500,
            ),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius:
                  BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.mint,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'How your score is calculated',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            'Your wellbeing score is a simple self-reflection measure based on three parts of your check-in: mood, energy, and sleep quality.',
            style: TextStyle(
              color:
              AppColors.navy.withValues(
                alpha: 0.58,
              ),
              fontSize: 10,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _buildScoreTag(
                  'Mood',
                  '1–10',
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: _buildScoreTag(
                  'Energy',
                  '1–10',
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: _buildScoreTag(
                  'Sleep',
                  '1–10',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreTag(
      String title,
      String value,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            value,
            style: TextStyle(
              color:
              AppColors.navy.withValues(
                alpha: 0.45,
              ),
              fontSize: 7.5,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DISCLAIMER
  // =========================================================

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color:
            AppColors.navy.withValues(
              alpha: 0.45,
            ),
            size: 16,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              'Your weekly score is intended for personal reflection and does not represent a clinical assessment or diagnosis.',
              style: TextStyle(
                color:
                AppColors.navy.withValues(
                  alpha: 0.48,
                ),
                fontSize: 8.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // COMMON CARD
  // =========================================================

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(21),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color:
            AppColors.navy.withValues(
              alpha: 0.035,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}