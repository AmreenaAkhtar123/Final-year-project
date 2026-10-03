import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../core/constants/app_colors.dart';
import 'ai_chat_screen.dart';
import 'assessments/assessments_screen.dart';
import 'mood_screen.dart';
import 'emotion_screen.dart';
import 'progress_screen.dart';
import 'weekly_wellbeing_screen.dart';
import 'exercise/calm_grounding_screen.dart';
import 'exercise/exam_pressure_reset_screen.dart';
import 'exercise/focus_reset_screen.dart';
import 'exercise/sleep_wind_down_screen.dart';
import 'exercise/stress_release_screen.dart';
import 'exercise/thought_reset_screen.dart';

class StudentWellbeingScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const StudentWellbeingScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  State<StudentWellbeingScreen> createState() =>
      _StudentWellbeingScreenState();
}

class _StudentWellbeingScreenState extends State<StudentWellbeingScreen> {
  // ---------------------------------------------------------------------------
  // COLORS
  // ---------------------------------------------------------------------------

  static const Color _navy = AppColors.navy;

  // Navy is intentionally NOT used for normal text, selected states,
  // borders, progress indicators, section headers, etc.
  static const Color _ink = Color(0xFF293438);
  static const Color _muted = Color(0xFF738084);
  static const Color _softText = Color(0xFF96A1A4);

  static const Color _mint = AppColors.mint;
  static const Color _lightMint = AppColors.lightMint;
  static const Color _border = AppColors.borderMint;

  static const Color _page = Color(0xFFFCFCFC);
  static const Color _white = Colors.white;

  static const Color _softGrey = Color(0xFFF4F7F6);
  static const Color _warningBg = Color(0xFFFFF8E8);
  static const Color _warning = Color(0xFFB88921);

  // ---------------------------------------------------------------------------
  // STUDENT INPUT
  // ---------------------------------------------------------------------------

  final Set<String> _struggles = {};
  final Set<String> _effects = {};
  final Set<String> _pressureSources = {};

  final TextEditingController _somethingElseController =
  TextEditingController();

  bool _showResults = false;

  // ---------------------------------------------------------------------------
  // ORIGINAL / EXISTING ANALYTICS DATA
  // ---------------------------------------------------------------------------
  //
  // These are professional demo values for now.
  // Later these can be replaced with MongoDB + CheckInService values.
  //

  double _studentPulse = 72;
  double _pressureIndex = 58;
  double _focusReadiness = 64;
  double _recoveryIndex = 55;
  double _overloadIndex = 46;

  double _academicHealth = 6.7;
  double _mentalHealth = 7.2;
  double _lifestyleHealth = 7.4;

  double _stress = 6;
  double _examPressure = 7;
  double _burnout = 5;
  double _sleep = 5;
  double _energy = 6;
  double _workload = 7;
  double _socialConnection = 6;
  double _motivation = 6;

  // ---------------------------------------------------------------------------
  // OPTIONS
  // ---------------------------------------------------------------------------

  final List<_StudentOption> _struggleOptions = const [
    _StudentOption(
      id: 'assignments',
      title: 'Assignments',
      subtitle: 'Coursework & tasks',
      icon: Icons.menu_book_rounded,
    ),
    _StudentOption(
      id: 'exams',
      title: 'Exams',
      subtitle: 'Tests & preparation',
      icon: Icons.fact_check_rounded,
    ),
    _StudentOption(
      id: 'deadlines',
      title: 'Deadlines',
      subtitle: 'Time pressure',
      icon: Icons.schedule_rounded,
    ),
    _StudentOption(
      id: 'projects',
      title: 'Projects / FYP',
      subtitle: 'Long-term work',
      icon: Icons.laptop_mac_rounded,
    ),
    _StudentOption(
      id: 'workload',
      title: 'Workload',
      subtitle: 'Too much to manage',
      icon: Icons.layers_rounded,
    ),
    _StudentOption(
      id: 'concentration',
      title: 'Concentration',
      subtitle: 'Staying focused',
      icon: Icons.center_focus_strong_rounded,
    ),
    _StudentOption(
      id: 'sleep',
      title: 'Sleep / Energy',
      subtitle: 'Rest & energy',
      icon: Icons.bedtime_rounded,
    ),
    _StudentOption(
      id: 'personal',
      title: 'Personal / Social',
      subtitle: 'Life outside study',
      icon: Icons.people_alt_rounded,
    ),
    _StudentOption(
      id: 'something_else',
      title: 'Something else',
      subtitle: 'Tell MindMate',
      icon: Icons.edit_note_rounded,
    ),
  ];

  final List<_StudentOption> _effectOptions = const [
    _StudentOption(
      id: 'stress',
      title: 'Stress',
      subtitle: 'Feeling tense',
      icon: Icons.bolt_rounded,
    ),
    _StudentOption(
      id: 'overwhelmed',
      title: 'Overwhelmed',
      subtitle: 'Too much at once',
      icon: Icons.waves_rounded,
    ),
    _StudentOption(
      id: 'exhausted',
      title: 'Exhausted',
      subtitle: 'Mentally or physically',
      icon: Icons.battery_2_bar_rounded,
    ),
    _StudentOption(
      id: 'low_motivation',
      title: 'Low motivation',
      subtitle: 'Hard to get started',
      icon: Icons.trending_down_rounded,
    ),
    _StudentOption(
      id: 'cant_focus',
      title: "Can't focus",
      subtitle: 'Mind keeps drifting',
      icon: Icons.filter_center_focus_rounded,
    ),
    _StudentOption(
      id: 'poor_sleep',
      title: 'Poor sleep',
      subtitle: 'Rest is affected',
      icon: Icons.nightlight_round,
    ),
    _StudentOption(
      id: 'overthinking',
      title: 'Overthinking',
      subtitle: 'Thoughts keep looping',
      icon: Icons.psychology_alt_rounded,
    ),
    _StudentOption(
      id: 'emotionally_drained',
      title: 'Emotionally drained',
      subtitle: 'Low emotional energy',
      icon: Icons.sentiment_dissatisfied_rounded,
    ),
    _StudentOption(
      id: 'okay',
      title: 'Feeling okay',
      subtitle: 'Managing fairly well',
      icon: Icons.sentiment_satisfied_alt_rounded,
    ),
  ];

  final List<_StudentOption> _pressureOptions = const [
    _StudentOption(
      id: 'academic',
      title: 'Academic workload',
      subtitle: 'Study demands',
      icon: Icons.school_rounded,
    ),
    _StudentOption(
      id: 'deadlines',
      title: 'Deadlines',
      subtitle: 'Limited time',
      icon: Icons.timer_rounded,
    ),
    _StudentOption(
      id: 'expectations',
      title: 'Expectations',
      subtitle: 'Pressure to perform',
      icon: Icons.track_changes_rounded,
    ),
    _StudentOption(
      id: 'personal',
      title: 'Personal',
      subtitle: 'Life circumstances',
      icon: Icons.person_outline_rounded,
    ),
    _StudentOption(
      id: 'financial',
      title: 'Financial',
      subtitle: 'Money concerns',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _StudentOption(
      id: 'relationships',
      title: 'Relationships',
      subtitle: 'People & connections',
      icon: Icons.favorite_border_rounded,
    ),
    _StudentOption(
      id: 'other',
      title: 'Other',
      subtitle: 'Something different',
      icon: Icons.more_horiz_rounded,
    ),
  ];

  // ---------------------------------------------------------------------------
  // DERIVED STATE
  // ---------------------------------------------------------------------------

  bool get _hasInput =>
      _struggles.isNotEmpty ||
          _effects.isNotEmpty ||
          _pressureSources.isNotEmpty;

  bool get _hasHighStress =>
      _effects.contains('stress') ||
          _effects.contains('overwhelmed');

  bool get _hasLowRecovery =>
      _effects.contains('exhausted') ||
          _effects.contains('poor_sleep') ||
          _effects.contains('emotionally_drained');

  bool get _hasFocusIssue =>
      _effects.contains('cant_focus') ||
          _struggles.contains('concentration');

  bool get _hasMotivationIssue =>
      _effects.contains('low_motivation');

  bool get _hasOverthinking =>
      _effects.contains('overthinking');

  bool get _hasAcademicPressure =>
      _struggles.contains('assignments') ||
          _struggles.contains('exams') ||
          _struggles.contains('deadlines') ||
          _struggles.contains('projects') ||
          _struggles.contains('workload') ||
          _pressureSources.contains('academic') ||
          _pressureSources.contains('deadlines');

  int get _strainSignals {
    int score = 0;

    if (_hasHighStress) score++;
    if (_hasLowRecovery) score++;
    if (_hasFocusIssue) score++;
    if (_hasMotivationIssue) score++;
    if (_hasOverthinking) score++;
    if (_hasAcademicPressure) score++;
    if (_effects.contains('emotionally_drained')) score++;

    return score;
  }

  String get _monitorTitle {
    if (_strainSignals >= 5) return 'High Strain';
    if (_strainSignals >= 3) return 'Needs Attention';
    return 'Stable';
  }

  String get _monitorDescription {
    if (_strainSignals >= 5) {
      return 'Your current responses suggest that several areas are putting pressure on your wellbeing.';
    }

    if (_strainSignals >= 3) {
      return 'You have reported a few areas that may benefit from some attention and support.';
    }

    return 'Your current responses do not show a strong overload signal.';
  }

  String get _primarySignal {
    if (_hasLowRecovery) return 'Recovery needs attention';
    if (_hasHighStress) return 'Stress is elevated';
    if (_hasFocusIssue) return 'Focus may need support';
    if (_hasMotivationIssue) return 'Motivation may be affected';
    if (_hasOverthinking) return 'Your mind may need a reset';
    if (_hasAcademicPressure) return 'Academic pressure is present';

    return 'Your wellbeing looks fairly balanced';
  }

  String get _aiInsight {
    final parts = <String>[];

    if (_hasAcademicPressure) {
      parts.add('You have identified academic demands as part of your current situation.');
    }

    if (_hasHighStress) {
      parts.add('You are also reporting stress or feeling overwhelmed.');
    }

    if (_hasLowRecovery) {
      parts.add('Recovery appears to be an important area to protect right now.');
    }

    if (_hasFocusIssue) {
      parts.add('Difficulty maintaining focus may be connected with the pressure you described.');
    }

    if (parts.isEmpty) {
      return 'Your responses suggest that you currently have a manageable situation. Keep checking in with yourself as your student life changes.';
    }

    return '${parts.join(' ')} This is a wellbeing reflection based on your responses, not a diagnosis.';
  }

  // ---------------------------------------------------------------------------
  // ACTION
  // ---------------------------------------------------------------------------

  Future<void> _generateWellbeingSnapshot() async {
    if (!_hasInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Tell MindMate a little about your situation first.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      return;
    }

    setState(() {
      double pressureAdjustment = 0;
      double recoveryAdjustment = 0;
      double focusAdjustment = 0;
      double pulseAdjustment = 0;

      pressureAdjustment += _pressureSources.length * 4;
      pressureAdjustment += _struggles.length * 2;

      if (_hasHighStress) {
        pressureAdjustment += 8;
        pulseAdjustment -= 7;
      }

      if (_hasLowRecovery) {
        recoveryAdjustment += 10;
        pulseAdjustment -= 6;
      }

      if (_hasFocusIssue) {
        focusAdjustment += 12;
        pulseAdjustment -= 4;
      }

      if (_hasMotivationIssue) {
        recoveryAdjustment += 5;
        pulseAdjustment -= 3;
      }

      if (_effects.contains('okay')) {
        pulseAdjustment += 6;
      }

      // -----------------------------------------------------------------------
      // CORE METRICS
      // -----------------------------------------------------------------------

      _pressureIndex =
          (58 + pressureAdjustment).clamp(0, 100).toDouble();

      _recoveryIndex =
          (55 - recoveryAdjustment).clamp(0, 100).toDouble();

      _focusReadiness =
          (64 - focusAdjustment).clamp(0, 100).toDouble();

      _overloadIndex =
          (46 + pressureAdjustment * 0.65)
              .clamp(0, 100)
              .toDouble();

      _studentPulse =
          (72 + pulseAdjustment).clamp(0, 100).toDouble();

      // -----------------------------------------------------------------------
      // WELLBEING INDICATORS
      // -----------------------------------------------------------------------

      _stress =
          (_hasHighStress ? 7.5 : 6.0)
              .clamp(0.0, 10.0)
              .toDouble();

      _energy =
          (_hasLowRecovery ? 4.0 : 6.0)
              .clamp(0.0, 10.0)
              .toDouble();

      _sleep =
          (_effects.contains('poor_sleep') ? 3.5 : 5.0)
              .clamp(0.0, 10.0)
              .toDouble();

      _motivation =
          (_hasMotivationIssue ? 4.0 : 6.0)
              .clamp(0.0, 10.0)
              .toDouble();

      _workload =
          (_hasAcademicPressure ? 7.5 : 6.5)
              .clamp(0.0, 10.0)
              .toDouble();

      _burnout =
          ((_stress +
              (10 - _energy) +
              (10 - _motivation)) /
              3)
              .clamp(0.0, 10.0)
              .toDouble();

      // -----------------------------------------------------------------------
      // WELLBEING AREAS
      // -----------------------------------------------------------------------

      _academicHealth =
          (_hasAcademicPressure ? 6.2 : 6.7)
              .clamp(0.0, 10.0)
              .toDouble();

      _mentalHealth =
          (_hasHighStress || _hasLowRecovery ? 6.4 : 7.2)
              .clamp(0.0, 10.0)
              .toDouble();

      _lifestyleHealth =
          (_hasLowRecovery ? 6.2 : 7.4)
              .clamp(0.0, 10.0)
              .toDouble();

      _showResults = true;
    });

    // Save the exact snapshot after the local calculations are complete.
    await _saveWellbeingSnapshot();
  }

  void _resetCheckpoint() {
    setState(() {
      _struggles.clear();
      _effects.clear();
      _pressureSources.clear();
      _somethingElseController.clear();
      _showResults = false;
    });
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION
  // ---------------------------------------------------------------------------

  void _openScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _openRecommendedAction() {
    if (_hasLowRecovery) {
      _openScreen(const SleepWindDownScreen());
      return;
    }

    if (_hasHighStress) {
      _openScreen(const StressReleaseScreen());
      return;
    }

    if (_hasOverthinking) {
      _openScreen(const ThoughtResetScreen());
      return;
    }

    if (_hasFocusIssue) {
      _openScreen(const FocusResetScreen());
      return;
    }

    if (_struggles.contains('exams')) {
      _openScreen(const ExamPressureResetScreen());
      return;
    }

    if (_effects.contains('okay')) {
      _openScreen(const CalmGroundingScreen());
      return;
    }

    _openScreen(const AiChatScreen());
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildTopBar(),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHero(),
                  const SizedBox(height: 28),

                  _buildCheckpointIntro(),
                  const SizedBox(height: 18),

                  _buildQuestionSection(
                    number: '01',
                    title: 'What are you dealing with?',
                    subtitle:
                    'Choose anything that feels relevant right now.',
                    options: _struggleOptions,
                    selected: _struggles,
                    allowMultiple: true,
                  ),

                  if (_struggles.contains('something_else')) ...[
                    const SizedBox(height: 12),
                    _buildSomethingElseField(),
                  ],

                  const SizedBox(height: 24),

                  _buildQuestionSection(
                    number: '02',
                    title: 'How is it affecting you?',
                    subtitle:
                    'Select the experiences that describe how you feel.',
                    options: _effectOptions,
                    selected: _effects,
                    allowMultiple: true,
                  ),

                  const SizedBox(height: 24),

                  _buildQuestionSection(
                    number: '03',
                    title: 'What is creating the most pressure?',
                    subtitle:
                    'There can be more than one reason.',
                    options: _pressureOptions,
                    selected: _pressureSources,
                    allowMultiple: true,
                  ),

                  const SizedBox(height: 22),

                  _buildUpdateButton(),

                  if (_showResults) ...[
                    const SizedBox(height: 34),
                    _buildCurrentState(),
                    const SizedBox(height: 28),
                    _buildCoreMetrics(),
                    const SizedBox(height: 28),
                    _buildWellbeingAreas(),
                    const SizedBox(height: 28),
                    _buildBurnoutSection(),
                    const SizedBox(height: 28),
                    _buildMonitor(),
                    const SizedBox(height: 28),
                    _buildWhatChanged(),
                    const SizedBox(height: 28),
                    _buildAiInsight(),
                    const SizedBox(height: 28),
                    _buildRecommendedActions(),
                    const SizedBox(height: 28),
                    _buildExistingTools(),
                    const SizedBox(height: 28),
                    _buildHistorySection(),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BAR
  // ---------------------------------------------------------------------------

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: _border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: _navy,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Wellbeing',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your personal student checkpoint',
                  style: TextStyle(
                    color: _muted,
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
              color: _lightMint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: _mint,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HERO
  // ---------------------------------------------------------------------------

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.14),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -38,
            top: -48,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _mint.withOpacity(0.18),
                  width: 24,
                ),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -60,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _mint.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _mint.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'STUDENT WELLBEING',
                      style: TextStyle(
                        color: _mint,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.insights_rounded,
                    color: _mint.withOpacity(0.9),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Understand what is\nhappening right now.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tell MindMate what you are dealing with and get a clearer picture of your pressure, focus and recovery.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 13.5,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INTRO
  // ---------------------------------------------------------------------------

  Widget _buildCheckpointIntro() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _lightMint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: _mint,
            size: 19,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'A few answers help MindMate personalize your wellbeing snapshot.',
            style: TextStyle(
              color: _muted,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // QUESTION SECTION
  // ---------------------------------------------------------------------------

  Widget _buildQuestionSection({
    required String number,
    required String title,
    required String subtitle,
    required List<_StudentOption> options,
    required Set<String> selected,
    required bool allowMultiple,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _lightMint,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: _mint,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
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
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...options.map(
                (option) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _buildSelectableOption(
                option: option,
                selected: selected.contains(option.id),
                onTap: () {
                  setState(() {
                    if (selected.contains(option.id)) {
                      selected.remove(option.id);
                    } else {
                      selected.add(option.id);
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SELECTABLE OPTION
  // ---------------------------------------------------------------------------

  Widget _buildSelectableOption({
    required _StudentOption option,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          // IMPORTANT:
          // selected = LIGHT MINT, NEVER NAVY.
          color: selected ? _lightMint : _softGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _mint : Colors.transparent,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: selected ? _mint.withOpacity(0.14) : _white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                color: _mint,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: TextStyle(
                      color: _ink,
                      fontSize: 13.5,
                      fontWeight:
                      selected ? FontWeight.w800 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _mint : Colors.transparent,
                border: Border.all(
                  color: selected ? _mint : _border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 14,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SOMETHING ELSE
  // ---------------------------------------------------------------------------

  Widget _buildSomethingElseField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lightMint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                color: _mint,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tell MindMate in your own words',
                style: TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _somethingElseController,
            maxLines: 3,
            style: const TextStyle(
              color: _ink,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText:
              'For example: I am finding it difficult to balance university and other responsibilities...',
              hintStyle: TextStyle(
                color: _muted.withOpacity(0.75),
                fontSize: 12,
                height: 1.4,
              ),
              filled: true,
              fillColor: _white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: _mint,
                  width: 1.2,
                ),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UPDATE BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _generateWellbeingSnapshot,
        style: ElevatedButton.styleFrom(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showResults
                  ? Icons.refresh_rounded
                  : Icons.auto_awesome_rounded,
              size: 19,
            ),
            const SizedBox(width: 9),
            Text(
              _showResults
                  ? 'Update My Wellbeing Snapshot'
                  : 'See My Wellbeing Snapshot',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CURRENT STATE
  // ---------------------------------------------------------------------------

  Widget _buildCurrentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          eyebrow: 'YOUR CURRENT STATE',
          title: 'What MindMate sees',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _stateCircle(
                    value: _studentPulse.round().toString(),
                    label: 'Pulse',
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _primarySignal,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _monitorDescription,
                          style: TextStyle(
                            color: _muted,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_hasAcademicPressure)
                    _miniMintTag('Academic pressure'),
                  if (_hasHighStress) _miniMintTag('Stress'),
                  if (_hasLowRecovery) _miniMintTag('Recovery'),
                  if (_hasFocusIssue) _miniMintTag('Focus'),
                  if (_hasOverthinking) _miniMintTag('Overthinking'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stateCircle({
    required String value,
    required String label,
  }) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _lightMint,
        border: Border.all(
          color: _mint.withOpacity(0.35),
          width: 7,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMintTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _lightMint,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _mint,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CORE METRICS
  // ---------------------------------------------------------------------------

  Widget _buildCoreMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          eyebrow: 'MINDMATE INTELLIGENCE',
          title: 'Your wellbeing signals',
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.42,
          children: [
            _metricCard(
              title: 'Student Pulse',
              value: '${_studentPulse.round()}',
              suffix: '/100',
              icon: Icons.favorite_rounded,
              progress: _studentPulse / 100,
            ),
            _metricCard(
              title: 'Pressure Index',
              value: '${_pressureIndex.round()}',
              suffix: '/100',
              icon: Icons.speed_rounded,
              progress: _pressureIndex / 100,
            ),
            _metricCard(
              title: 'Focus Readiness',
              value: '${_focusReadiness.round()}',
              suffix: '/100',
              icon: Icons.center_focus_strong_rounded,
              progress: _focusReadiness / 100,
            ),
            _metricCard(
              title: 'Recovery Index',
              value: '${_recoveryIndex.round()}',
              suffix: '/100',
              icon: Icons.battery_charging_full_rounded,
              progress: _recoveryIndex / 100,
            ),
            _metricCard(
              title: 'Overload Index',
              value: '${_overloadIndex.round()}',
              suffix: '/100',
              icon: Icons.stacked_bar_chart_rounded,
              progress: _overloadIndex / 100,
            ),
            _metricCard(
              title: 'Burnout Signal',
              value: _burnout.toStringAsFixed(1),
              suffix: '/10',
              icon: Icons.local_fire_department_outlined,
              progress: _burnout / 10,
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String suffix,
    required IconData icon,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _lightMint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: _mint,
                  size: 17,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  suffix,
                  style: const TextStyle(
                    color: _softText,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 5,
              backgroundColor: _lightMint,
              valueColor: const AlwaysStoppedAnimation<Color>(_mint),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _saveWellbeingSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedEmail = prefs.getString('logged_in_email');

      if (savedEmail == null || savedEmail.trim().isEmpty) {
        debugPrint(
          'Student wellbeing save failed: logged-in email not found.',
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to identify your account.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return;
      }

      final email = savedEmail.trim().toLowerCase();

      final response = await http.post(
        Uri.parse(ApiConfig.studentWellbeingUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,

          // User selections
          'dealingWith': _struggles.toList(),
          'effects': _effects.toList(),
          'pressureSources': _pressureSources.toList(),

          // Actual text entered by the student
          'somethingElse':
          _somethingElseController.text.trim(),

          // Core metrics
          'studentPulse': _studentPulse,
          'pressureIndex': _pressureIndex,
          'focusReadiness': _focusReadiness,
          'recoveryIndex': _recoveryIndex,
          'overloadIndex': _overloadIndex,

          // Wellbeing indicators
          'stress': _stress,
          'examPressure': _examPressure,
          'burnout': _burnout,
          'sleep': _sleep,
          'energy': _energy,
          'workload': _workload,
          'socialConnection': _socialConnection,
          'motivation': _motivation,

          // Wellbeing areas
          'academicHealth': _academicHealth,
          'mentalHealth': _mentalHealth,
          'lifestyleHealth': _lifestyleHealth,

          // Current interpretation
          'monitorStatus': _monitorTitle,
          'primarySignal': _primarySignal,
          'aiInsight': _aiInsight,
        }),
      );

      debugPrint(
        'Student wellbeing response: '
            '${response.statusCode}',
      );

      debugPrint(
        'Student wellbeing response body: '
            '${response.body}',
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your wellbeing snapshot has been saved.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to save your wellbeing snapshot.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      debugPrint(
        'Student wellbeing connection error: $error',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not connect to the MindMate server.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  // ---------------------------------------------------------------------------
  // PRESSURE / RECOVERY
  // ---------------------------------------------------------------------------

  Widget _buildPressureRecovery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          eyebrow: 'PRESSURE & RECOVERY',
          title: 'How your system is balancing',
        ),
        const SizedBox(height: 14),
        _largeAnalyticsCard(
          title: 'Pressure load',
          value: '${_pressureIndex.round()}',
          description:
          'A combined view of workload, pressure sources and reported stress.',
          icon: Icons.trending_up_rounded,
          progress: _pressureIndex / 100,
        ),
        const SizedBox(height: 12),
        _largeAnalyticsCard(
          title: 'Recovery capacity',
          value: '${_recoveryIndex.round()}',
          description:
          'Reflects energy, sleep, emotional recovery and motivation signals.',
          icon: Icons.spa_rounded,
          progress: _recoveryIndex / 100,
        ),
        const SizedBox(height: 12),
        _largeAnalyticsCard(
          title: 'Focus readiness',
          value: '${_focusReadiness.round()}',
          description:
          'Reflects how prepared you currently feel to concentrate and engage.',
          icon: Icons.psychology_rounded,
          progress: _focusReadiness / 100,
        ),
      ],
    );
  }

  Widget _largeAnalyticsCard({
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _lightMint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: _mint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              description,
              style: const TextStyle(
                color: _muted,
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 6,
              backgroundColor: _lightMint,
              valueColor: const AlwaysStoppedAnimation<Color>(_mint),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WELLBEING AREAS
  // ---------------------------------------------------------------------------

  Widget _buildWellbeingAreas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          eyebrow: 'WELLBEING AREAS',
          title: 'The bigger picture',
        ),
        const SizedBox(height: 14),
        _areaCard(
          title: 'Academic',
          value: _academicHealth,
          icon: Icons.school_outlined,
          description: 'Workload, pressure and study demands.',
        ),
        const SizedBox(height: 10),
        _areaCard(
          title: 'Mental wellbeing',
          value: _mentalHealth,
          icon: Icons.psychology_outlined,
          description: 'Stress, emotions, motivation and mental load.',
        ),
        const SizedBox(height: 10),
        _areaCard(
          title: 'Lifestyle',
          value: _lifestyleHealth,
          icon: Icons.self_improvement_rounded,
          description: 'Sleep, energy, recovery and balance.',
        ),
      ],
    );
  }

  Widget _areaCard({
    required String title,
    required double value,
    required IconData icon,
    required String description,
  }) {
    final progress = (value / 10).clamp(0, 1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _lightMint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: _mint,
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
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress.toDouble().clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: _lightMint,
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(_mint),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BURNOUT
  // ---------------------------------------------------------------------------

  Widget _buildBurnoutSection() {
    final burnoutHigh = _burnout >= 6.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          eyebrow: 'BURNOUT MONITOR',
          title: 'Energy, motivation & recovery',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: burnoutHigh
                          ? _warningBg
                          : _lightMint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      burnoutHigh
                          ? Icons.warning_amber_rounded
                          : Icons.battery_5_bar_rounded,
                      color: burnoutHigh ? _warning : _mint,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          burnoutHigh
                              ? 'Higher strain pattern'
                              : 'Current strain pattern',
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'This is a wellbeing signal, not a diagnosis.',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _burnout.toStringAsFixed(1),
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _burnoutRow(
                label: 'Energy',
                value: _energy,
                inverse: true,
              ),
              _burnoutRow(
                label: 'Motivation',
                value: _motivation,
                inverse: true,
              ),
              _burnoutRow(
                label: 'Mental exhaustion',
                value: _stress,
                inverse: false,
              ),
              _burnoutRow(
                label: 'Recovery',
                value: _sleep,
                inverse: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _burnoutRow({
    required String label,
    required double value,
    required bool inverse,
  }) {
    final displayValue = inverse ? value : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: (displayValue / 10).clamp(0, 1),
                minHeight: 6,
                backgroundColor: _lightMint,
                valueColor:
                const AlwaysStoppedAnimation<Color>(_mint),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 25,
            child: Text(
              displayValue.toStringAsFixed(0),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _ink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MONITOR
  // ---------------------------------------------------------------------------

  Widget _buildMonitor() {
    final high = _strainSignals >= 5;
    final attention = _strainSignals >= 3;

    final Color statusColor = high
        ? _warning
        : attention
        ? _mint
        : _mint;

    final Color statusBackground =
    high ? _warningBg : _lightMint;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusBackground,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: high ? _warning.withOpacity(0.25) : _border,
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
                  color: _white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  high
                      ? Icons.priority_high_rounded
                      : Icons.monitor_heart_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MindMate Monitor',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _monitorTitle,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _monitorDescription,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          if (high) ...[
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Your responses suggest you may need some additional support right now. Consider talking with someone you trust or using MindMate support tools.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WHAT CHANGED
  // ---------------------------------------------------------------------------

  Widget _buildWhatChanged() {
    final changes = <String>[];

    if (_hasHighStress) {
      changes.add('Stress signals are higher than your baseline snapshot.');
    }

    if (_hasLowRecovery) {
      changes.add('Recovery indicators are currently lower.');
    }

    if (_hasFocusIssue) {
      changes.add('Focus readiness may be affected by your current situation.');
    }

    if (_hasAcademicPressure) {
      changes.add('Academic demands are contributing to your current pressure.');
    }

    if (changes.isEmpty) {
      changes.add(
        'No major strain signal was identified from this checkpoint.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          eyebrow: 'PATTERN',
          title: 'What stands out',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: changes
                .map(
                  (text) => Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _mint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // AI INSIGHT
  // ---------------------------------------------------------------------------

  Widget _buildAiInsight() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(25),
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
                  color: _mint.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: _mint,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'MindMate Insight',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _aiInsight,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 12.5,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your wellbeing can change from day to day. Check in again whenever your situation changes.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RECOMMENDED ACTIONS
  // ---------------------------------------------------------------------------

  Widget _buildRecommendedActions() {
    final actions = <_ActionItem>[];

    if (_hasLowRecovery) {
      actions.add(
        const _ActionItem(
          title: 'Wind down & recover',
          subtitle: 'Create space for better sleep and recovery.',
          icon: Icons.bedtime_rounded,
          type: _ActionType.sleep,
        ),
      );
    }

    if (_hasHighStress) {
      actions.add(
        const _ActionItem(
          title: 'Release some stress',
          subtitle: 'Try a short guided stress reset.',
          icon: Icons.spa_rounded,
          type: _ActionType.stress,
        ),
      );
    }

    if (_hasFocusIssue) {
      actions.add(
        const _ActionItem(
          title: 'Reset your focus',
          subtitle: 'Take a short break and restart intentionally.',
          icon: Icons.center_focus_strong_rounded,
          type: _ActionType.focus,
        ),
      );
    }

    if (_hasOverthinking) {
      actions.add(
        const _ActionItem(
          title: 'Quiet the mental loop',
          subtitle: 'Use a guided thought reset.',
          icon: Icons.psychology_alt_rounded,
          type: _ActionType.thought,
        ),
      );
    }

    if (_struggles.contains('exams')) {
      actions.add(
        const _ActionItem(
          title: 'Exam pressure reset',
          subtitle: 'Work through exam-related pressure.',
          icon: Icons.fact_check_rounded,
          type: _ActionType.exam,
        ),
      );
    }

    if (actions.isEmpty) {
      actions.add(
        const _ActionItem(
          title: 'Take a calm moment',
          subtitle: 'Use a short grounding exercise.',
          icon: Icons.self_improvement_rounded,
          type: _ActionType.calm,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          eyebrow: 'NEXT STEP',
          title: 'What could help right now?',
        ),
        const SizedBox(height: 14),
        ...actions.take(3).map(
              (action) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildActionCard(action),
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _openScreen(const AiChatScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Talk to MindMate',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(_ActionItem action) {
    return GestureDetector(
      onTap: () => _handleAction(action.type),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: _lightMint,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                action.icon,
                color: _mint,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action.subtitle,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _mint,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(_ActionType type) {
    switch (type) {
      case _ActionType.sleep:
        _openScreen(const SleepWindDownScreen());
        break;
      case _ActionType.stress:
        _openScreen(const StressReleaseScreen());
        break;
      case _ActionType.focus:
        _openScreen(const FocusResetScreen());
        break;
      case _ActionType.thought:
        _openScreen(const ThoughtResetScreen());
        break;
      case _ActionType.exam:
        _openScreen(const ExamPressureResetScreen());
        break;
      case _ActionType.calm:
        _openScreen(const CalmGroundingScreen());
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // EXISTING TOOLS
  // ---------------------------------------------------------------------------

  Widget _buildExistingTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          eyebrow: 'YOUR MINDMATE TOOLKIT',
          title: 'Explore more',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            _toolButton(
              'Mood check',
              Icons.mood_rounded,
                  () => _openScreen(const MoodScreen()),
            ),
            _toolButton(
              'Emotions',
              Icons.emoji_emotions_outlined,
                  () => _openScreen(const EmotionScreen()),
            ),
            _toolButton(
              'Assessments',
              Icons.assignment_outlined,
                  () => _openScreen(const AssessmentsScreen()),
            ),
            _toolButton(
              'Focus reset',
              Icons.center_focus_strong_rounded,
                  () => _openScreen(const FocusResetScreen()),
            ),
            _toolButton(
              'Calm',
              Icons.self_improvement_rounded,
                  () => _openScreen(const CalmGroundingScreen()),
            ),
            _toolButton(
              'Talk',
              Icons.chat_bubble_outline_rounded,
                  () => _openScreen(const AiChatScreen()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _toolButton(
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _mint,
              size: 17,
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: const TextStyle(
                color: _ink,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HISTORY
  // ---------------------------------------------------------------------------

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          eyebrow: 'YOUR PATTERNS',
          title: 'Keep understanding yourself',
        ),
        const SizedBox(height: 14),
        _historyCard(
          icon: Icons.show_chart_rounded,
          title: 'View Progress',
          subtitle:
          'See your longer-term wellbeing patterns and changes.',
          onTap: () => _openScreen(const ProgressScreen()),
        ),
        const SizedBox(height: 10),
        _historyCard(
          icon: Icons.calendar_month_rounded,
          title: 'Weekly Wellbeing',
          subtitle:
          'Review your weekly check-ins, mood and recovery patterns.',
          onTap: () => _openScreen(const WeeklyWellbeingScreen()),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: _resetCheckpoint,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _lightMint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_rounded,
                  color: _mint,
                  size: 17,
                ),
                SizedBox(width: 7),
                Text(
                  'Update my situation',
                  style: TextStyle(
                    color: _mint,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _historyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: _lightMint,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: _mint,
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
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _mint,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION HEADING
  // ---------------------------------------------------------------------------

  Widget _sectionHeading({
    required String eyebrow,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: _mint,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.25,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.35,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _somethingElseController.dispose();
    super.dispose();
  }
}

// =============================================================================
// MODELS
// =============================================================================

class _StudentOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const _StudentOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final _ActionType type;

  const _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
  });
}

enum _ActionType {
  sleep,
  stress,
  focus,
  thought,
  exam,
  calm,
}