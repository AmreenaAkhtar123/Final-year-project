import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class StudentWellbeingScreen extends StatefulWidget {
  const StudentWellbeingScreen({super.key});

  @override
  State<StudentWellbeingScreen> createState() =>
      _StudentWellbeingScreenState();
}

class _StudentWellbeingScreenState extends State<StudentWellbeingScreen> {
  // ------------------------------------------------------------
  // DEMO / UI DATA
  // ------------------------------------------------------------

  double _stress = 6;
  double _examPressure = 7;
  double _burnout = 5;

  double _sleep = 5;
  double _energy = 6;
  double _workload = 7;
  double _socialConnection = 6;
  double _motivation = 6;

  bool _showDetails = false;

  // ------------------------------------------------------------
  // CALCULATIONS
  // ------------------------------------------------------------

  double get _overallScore {
    final pressureScore =
    ((_stress + _examPressure + _burnout) / 3);

    final wellbeingFactors =
    ((_sleep + _energy + _socialConnection + _motivation) / 4);

    final score = ((10 - pressureScore) * 0.55) +
        (wellbeingFactors * 0.45);

    return score.clamp(0, 10);
  }

  String get _overallLabel {
    if (_overallScore >= 7.5) {
      return 'Doing Well';
    } else if (_overallScore >= 5) {
      return 'Needs Attention';
    }

    return 'High Pressure';
  }

  Color get _overallColor {
    if (_overallScore >= 7.5) {
      return AppColors.mint;
    } else if (_overallScore >= 5) {
      return const Color(0xFFD99A3D);
    }

    return const Color(0xFFD86B6B);
  }

  String get _mainConcern {
    final values = {
      'Stress': _stress,
      'Exam Pressure': _examPressure,
      'Burnout': _burnout,
      'Study Workload': _workload,
    };

    return values.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
    ).key;
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.navy,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Student Wellbeing',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showInfoDialog,
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.navy,
              size: 21,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(),

            const SizedBox(height: 24),

            _buildSectionHeader(
              'Student Wellbeing Check',
              'Reflect on the areas that can affect your student life.',
            ),

            const SizedBox(height: 18),

            _buildAssessmentCard(
              icon: Icons.bolt_rounded,
              title: 'Stress',
              description:
              'How much stress have you been experiencing recently?',
              value: _stress,
              onChanged: (value) {
                setState(() => _stress = value);
              },
            ),

            const SizedBox(height: 14),

            _buildAssessmentCard(
              icon: Icons.menu_book_rounded,
              title: 'Exam Pressure',
              description:
              'How much pressure are your studies or exams causing?',
              value: _examPressure,
              onChanged: (value) {
                setState(() => _examPressure = value);
              },
            ),

            const SizedBox(height: 14),

            _buildAssessmentCard(
              icon: Icons.battery_alert_rounded,
              title: 'Burnout',
              description:
              'How mentally and emotionally exhausted have you been?',
              value: _burnout,
              onChanged: (value) {
                setState(() => _burnout = value);
              },
            ),

            const SizedBox(height: 26),

            _buildSectionHeader(
              'Student-Life Factors',
              'These areas can influence your overall wellbeing.',
            ),

            const SizedBox(height: 18),

            _buildFactorGrid(),

            const SizedBox(height: 22),

            _buildDetailsButton(),

            if (_showDetails) ...[
              const SizedBox(height: 16),
              _buildDetailedSummary(),
            ],

            const SizedBox(height: 22),

            _buildSubmitButton(),


            const SizedBox(height: 26),

            _buildInsightCard(),

            const SizedBox(height: 22),

            _buildHistoryCard(),


            const SizedBox(height: 18),

            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submitWellbeingReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 21,
            ),
            SizedBox(width: 9),
            Text(
              'Submit Wellbeing Report',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitWellbeingReport() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Wellbeing Report Submitted',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: AppColors.mint,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Overall wellbeing: '
                            '${_overallScore.toStringAsFixed(1)}/10',
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Your responses have been reviewed as a wellbeing reflection.',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.62),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Main area to watch: $_mainConcern',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  // ------------------------------------------------------------
  // OVERVIEW
  // ------------------------------------------------------------

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.navy,
            AppColors.navy.withValues(alpha: 0.91),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.school_rounded,
                color: AppColors.mint,
                size: 22,
              ),
              SizedBox(width: 9),
              Text(
                'YOUR WELLBEING',
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 112,
                      height: 112,
                      child: CircularProgressIndicator(
                        value: _overallScore / 10,
                        strokeWidth: 9,
                        backgroundColor:
                        Colors.white.withValues(alpha: 0.12),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(_overallColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _overallScore.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '/ 10',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _overallLabel,
                      style: TextStyle(
                        color: _overallColor,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'Your current wellbeing picture based on your check-in responses.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.flag_outlined,
                  color: AppColors.mint,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Main area to watch: $_mainConcern',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

  // ------------------------------------------------------------
  // SECTION HEADER
  // ------------------------------------------------------------

  Widget _buildSectionHeader(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.52),
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // MAIN ASSESSMENT CARD
  // ------------------------------------------------------------

  Widget _buildAssessmentCard({
    required IconData icon,
    required String title,
    required String description,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    //final percentage = value / 10;

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
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.mint,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.53),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '${value.toInt()}/10',
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),


          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.mint,
              inactiveTrackColor: AppColors.borderMint,
              thumbColor: AppColors.mint,
              overlayColor:
              AppColors.mint.withValues(alpha: 0.12),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.42),
                  fontSize: 10,
                ),
              ),
              Text(
                'High',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.42),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FACTOR GRID
  // ------------------------------------------------------------

  Widget _buildFactorGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFactorCard(
                icon: Icons.bedtime_outlined,
                title: 'Sleep',
                value: _sleep,
                onChanged: (value) {
                  setState(() => _sleep = value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFactorCard(
                icon: Icons.battery_5_bar_rounded,
                title: 'Energy',
                value: _energy,
                onChanged: (value) {
                  setState(() => _energy = value);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildFactorCard(
                icon: Icons.menu_book_outlined,
                title: 'Workload',
                value: _workload,
                onChanged: (value) {
                  setState(() => _workload = value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFactorCard(
                icon: Icons.people_outline_rounded,
                title: 'Social',
                value: _socialConnection,
                onChanged: (value) {
                  setState(() => _socialConnection = value);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _buildFactorCard(
          icon: Icons.psychology_alt_outlined,
          title: 'Motivation',
          value: _motivation,
          onChanged: (value) {
            setState(() => _motivation = value);
          },
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildFactorCard({
    required IconData icon,
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    bool fullWidth = false,
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
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.mint,
                size: 21,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${value.toInt()}',
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.mint,
              inactiveTrackColor: AppColors.borderMint,
              thumbColor: AppColors.mint,
              overlayColor:
              AppColors.mint.withValues(alpha: 0.1),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // INSIGHT
  // ------------------------------------------------------------

  Widget _buildInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.mint,
                size: 22,
              ),
              SizedBox(width: 9),
              Text(
                'WELLBEING INSIGHT',
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            _buildInsightText(),
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            _buildSuggestionText(),
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.58),
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _buildInsightText() {
    if (_examPressure >= 8) {
      return 'Exam pressure is currently one of the strongest areas affecting your wellbeing.';
    }

    if (_stress >= 8) {
      return 'Your current stress level appears to be one of the main areas needing attention.';
    }

    if (_burnout >= 8) {
      return 'Your responses show a high level of mental and emotional exhaustion.';
    }

    if (_sleep <= 4) {
      return 'Your sleep level may be affecting your energy and ability to manage academic pressure.';
    }

    return 'Your responses show a mix of academic pressure and positive wellbeing factors.';
  }

  String _buildSuggestionText() {
    if (_examPressure >= 8) {
      return 'Consider breaking large study tasks into smaller sessions and scheduling regular recovery breaks.';
    }

    if (_stress >= 8) {
      return 'Try creating a short daily reset routine and identifying the specific situations contributing to your stress.';
    }

    if (_burnout >= 8) {
      return 'Prioritize recovery, sleep and meaningful breaks rather than continuously increasing study time.';
    }

    if (_sleep <= 4) {
      return 'A consistent sleep routine and reducing late-night study sessions may help support your daily energy.';
    }

    return 'Keep checking in with yourself regularly so you can notice changes before pressure builds up.';
  }

  // ------------------------------------------------------------
  // HISTORY
  // ------------------------------------------------------------

  Widget _buildHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: AppColors.navy,
                size: 21,
              ),
              SizedBox(width: 9),
              Text(
                'RECENT CHECKS',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          _buildHistoryRow(
            'Today',
            'Current check-in',
            _overallScore,
          ),

          const Divider(height: 22),

          _buildHistoryRow(
            'Sep 15',
            'Previous check-in',
            5.9,
          ),

          const Divider(height: 22),

          _buildHistoryRow(
            'Sep 12',
            'Previous check-in',
            4.7,
          ),

          const Divider(height: 22),

          _buildHistoryRow(
            'Sep 08',
            'Previous check-in',
            6.1,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(
      String date,
      String subtitle,
      double score,
      ) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.insights_rounded,
            color: AppColors.mint,
            size: 21,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.45),
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),

        Text(
          '${score.toStringAsFixed(1)}/10',
          style: const TextStyle(
            color: AppColors.mint,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // DETAILS
  // ------------------------------------------------------------

  Widget _buildDetailsButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _showDetails = !_showDetails;
          });
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: AppColors.borderMint,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _showDetails
                  ? 'Hide Detailed Summary'
                  : 'View Detailed Summary',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _showDetails
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppColors.navy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          _buildSummaryMetric(
            'Stress',
            _stress,
            Icons.bolt_rounded,
          ),
          const SizedBox(height: 15),
          _buildSummaryMetric(
            'Exam Pressure',
            _examPressure,
            Icons.menu_book_rounded,
          ),
          const SizedBox(height: 15),
          _buildSummaryMetric(
            'Burnout',
            _burnout,
            Icons.battery_alert_rounded,
          ),
          const SizedBox(height: 15),
          _buildSummaryMetric(
            'Sleep',
            _sleep,
            Icons.bedtime_outlined,
          ),
          const SizedBox(height: 15),
          _buildSummaryMetric(
            'Energy',
            _energy,
            Icons.battery_5_bar_rounded,
          ),
          const SizedBox(height: 15),
          _buildSummaryMetric(
            'Motivation',
            _motivation,
            Icons.psychology_alt_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(
      String title,
      double value,
      IconData icon,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.mint,
          size: 20,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 105,
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / 10,
              minHeight: 7,
              backgroundColor: AppColors.lightMint,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          '${value.toInt()}/10',
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // DISCLAIMER
  // ------------------------------------------------------------

  Widget _buildDisclaimer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: AppColors.navy.withValues(alpha: 0.35),
          size: 17,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'This wellbeing check is intended for self-reflection and '
                'awareness. It is not a medical or psychological diagnosis.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.4),
              fontSize: 10.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // INFO DIALOG
  // ------------------------------------------------------------

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'About Student Wellbeing',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'This section helps you reflect on common student-life '
                'factors such as academic stress, exam pressure, burnout, '
                'sleep, energy and motivation.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.62),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}