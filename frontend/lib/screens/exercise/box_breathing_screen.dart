import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  State<BoxBreathingScreen> createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;

  late AnimationController _breathingController;

  int _selectedRounds = 4;
  int _currentRound = 1;
  int _phaseIndex = 0;
  int _secondsRemaining = 4;

  int _beforeLevel = 3;
  int _afterLevel = 3;

  bool _sessionStarted = false;
  bool _sessionComplete = false;

  final List<String> _phases = [
    'INHALE',
    'HOLD',
    'EXHALE',
    'HOLD',
  ];

  final List<String> _phaseInstructions = [
    'Slowly breathe in',
    'Gently hold your breath',
    'Slowly breathe out',
    'Rest before the next breath',
  ];

  final List<IconData> _phaseIcons = [
    Icons.arrow_upward_rounded,
    Icons.pause_rounded,
    Icons.arrow_downward_rounded,
    Icons.pause_rounded,
  ];

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionComplete) {
      return _buildResultScreen();
    }

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
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 22),
                    _buildBeforeCheck(),
                    const SizedBox(height: 22),
                    if (!_sessionStarted)
                      _buildPreparationCard()
                    else
                      _buildBreathingExercise(),
                    const SizedBox(height: 22),
                    _buildHowItWorks(),
                    const SizedBox(height: 20),
                    _buildSafetyNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        20,
        10,
      ),
      child: Row(
        children: [
          Material(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                if (_sessionStarted) {
                  _showLeaveDialog();
                } else {
                  Navigator.pop(context);
                }
              },
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 19,
                  color: AppColors.navy,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Box Breathing',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Slow down. Breathe in. Reset.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '4 × 4',
              style: TextStyle(
                color: AppColors.mint,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HERO
  // ------------------------------------------------------------

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightMint,
            AppColors.background,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.air_rounded,
              color: AppColors.mint,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create a steady rhythm.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Box breathing follows four equal steps. '
                      'Let the animation guide your attention '
                      'instead of counting in your head.',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    height: 1.5,
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
  // BEFORE CHECK
  // ------------------------------------------------------------

  Widget _buildBeforeCheck() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Before we begin',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'How settled does your body feel right now?',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
                  (index) {
                final value = index + 1;
                final selected = _beforeLevel == value;

                return GestureDetector(
                  onTap: _sessionStarted
                      ? null
                      : () {
                    setState(() {
                      _beforeLevel = value;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.mint
                          : AppColors.lightMint,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: selected
                            ? AppColors.mint
                            : AppColors.borderMint,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$value',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 9),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Restless',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
              Text(
                'Very settled',
                style: TextStyle(
                  color: Colors.grey,
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
  // PREPARATION
  // ------------------------------------------------------------

  Widget _buildPreparationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.mint.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.self_improvement_rounded,
              color: AppColors.mint,
              size: 39,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Ready to find your rhythm?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will complete $_selectedRounds rounds. '
                'Each round has four equal 4-second phases.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 21),
          _buildRoundSelector(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 51,
            child: ElevatedButton.icon(
              onPressed: _startExercise,
              icon: const Icon(
                Icons.play_arrow_rounded,
              ),
              label: const Text(
                'Begin Box Breathing',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundSelector() {
    const rounds = [2, 4, 6, 8];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NUMBER OF ROUNDS',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.60),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: rounds.map((round) {
            final selected = _selectedRounds == round;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: round == rounds.last ? 0 : 7,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRounds = round;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 43,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.mint
                          : Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: selected
                            ? AppColors.mint
                            : Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$round',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // BREATHING EXERCISE
  // ------------------------------------------------------------

  Widget _buildBreathingExercise() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR BREATHING RHYTHM',
                      style: TextStyle(
                        color: AppColors.mint,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Round $_currentRound of $_selectedRounds',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPhaseCounter(),
            ],
          ),
          const SizedBox(height: 20),
          _buildBreathingVisual(),
          const SizedBox(height: 20),
          Text(
            _phases[_phaseIndex],
            style: const TextStyle(
              color: AppColors.mint,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _phaseInstructions[_phaseIndex],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$_secondsRemaining',
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          _buildPhaseIndicator(),
        ],
      ),
    );
  }

  Widget _buildPhaseCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.loop_rounded,
            color: AppColors.mint,
            size: 17,
          ),
          const SizedBox(width: 6),
          Text(
            '$_currentRound / $_selectedRounds',
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingVisual() {
    return SizedBox(
      width: 255,
      height: 255,
      child: AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          final progress = _breathingController.value;

          double scale;

          if (_phaseIndex == 0) {
            scale = 0.72 + (progress * 0.28);
          } else if (_phaseIndex == 1) {
            scale = 1.0;
          } else if (_phaseIndex == 2) {
            scale = 1.0 - (progress * 0.28);
          } else {
            scale = 0.72;
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightMint.withValues(alpha: 0.45),
                ),
              ),
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 165,
                  height: 165,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.mint,
                        AppColors.navy,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mint.withValues(alpha: 0.22),
                        blurRadius: 28,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _BoxBreathingPainter(),
                    child: Center(
                      child: Icon(
                        _phaseIcons[_phaseIndex],
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 2,
                child: _buildCornerLabel(
                  'INHALE',
                  _phaseIndex == 0,
                ),
              ),
              Positioned(
                right: 0,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: _buildCornerLabel(
                    'HOLD',
                    _phaseIndex == 1,
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                child: _buildCornerLabel(
                  'EXHALE',
                  _phaseIndex == 2,
                ),
              ),
              Positioned(
                left: 0,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: _buildCornerLabel(
                    'HOLD',
                    _phaseIndex == 3,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCornerLabel(
      String text,
      bool active,
      ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppColors.mint
            : AppColors.lightMint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active
              ? Colors.white
              : AppColors.navy.withValues(alpha: 0.55),
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildPhaseIndicator() {
    return Row(
      children: List.generate(
        4,
            (index) {
          final active = index == _phaseIndex;

          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(
                right: index == 3 ? 0 : 5,
              ),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.mint
                    : AppColors.borderMint,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // TIMER
  // ------------------------------------------------------------

  void _startExercise() {
    setState(() {
      _sessionStarted = true;
      _sessionComplete = false;
      _currentRound = 1;
      _phaseIndex = 0;
      _secondsRemaining = 4;
    });

    _startPhaseAnimation();
    _startTimer();
  }

  void _startPhaseAnimation() {
    _breathingController.stop();
    _breathingController.reset();

    if (_phaseIndex == 0 || _phaseIndex == 2) {
      _breathingController.duration =
      const Duration(seconds: 4);
    } else {
      _breathingController.duration =
      const Duration(seconds: 4);
    }

    _breathingController.forward();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining > 1) {
          setState(() {
            _secondsRemaining--;
          });
          return;
        }

        _moveToNextPhase();
      },
    );
  }

  void _moveToNextPhase() {
    if (_phaseIndex < 3) {
      setState(() {
        _phaseIndex++;
        _secondsRemaining = 4;
      });

      _startPhaseAnimation();
      return;
    }

    if (_currentRound < _selectedRounds) {
      setState(() {
        _currentRound++;
        _phaseIndex = 0;
        _secondsRemaining = 4;
      });

      _startPhaseAnimation();
      return;
    }

    _finishExercise();
  }

  void _finishExercise() {
    _timer?.cancel();
    _breathingController.stop();

    setState(() {
      _sessionStarted = false;
      _sessionComplete = true;
      _afterLevel = (_beforeLevel + 1).clamp(1, 5);
    });
  }

  // ------------------------------------------------------------
  // HOW IT WORKS
  // ------------------------------------------------------------

  Widget _buildHowItWorks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How box breathing works',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          _buildStep(
            number: '1',
            title: 'Inhale',
            text: 'Breathe in gently for 4 seconds.',
            icon: Icons.arrow_upward_rounded,
          ),
          _buildConnector(),
          _buildStep(
            number: '2',
            title: 'Hold',
            text: 'Keep your breath comfortably for 4 seconds.',
            icon: Icons.pause_rounded,
          ),
          _buildConnector(),
          _buildStep(
            number: '3',
            title: 'Exhale',
            text: 'Release the breath slowly for 4 seconds.',
            icon: Icons.arrow_downward_rounded,
          ),
          _buildConnector(),
          _buildStep(
            number: '4',
            title: 'Hold',
            text: 'Pause gently for another 4 seconds.',
            icon: Icons.pause_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String text,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.mint,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$number. $title',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Container(
      margin: const EdgeInsets.only(
        left: 18,
        top: 3,
        bottom: 3,
      ),
      height: 13,
      width: 2,
      color: AppColors.borderMint,
    );
  }

  // ------------------------------------------------------------
  // RESULT SCREEN
  // ------------------------------------------------------------

  Widget _buildResultScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                20,
                10,
              ),
              child: Row(
                children: [
                  Material(
                    color: AppColors.lightMint,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const SizedBox(
                        width: 46,
                        height: 46,
                        child: Icon(
                          Icons.close_rounded,
                          size: 21,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Breathing Complete',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  30,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildCompletionIcon(),
                    const SizedBox(height: 20),
                    const Text(
                      'You found your rhythm.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You gave yourself a few quiet minutes '
                          'to slow down and follow one steady pattern.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildResultSummary(),
                    const SizedBox(height: 20),
                    _buildReflectionCard(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _restartExercise,
                        icon: const Icon(
                          Icons.refresh_rounded,
                        ),
                        label: const Text(
                          'Breathe Again',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mint,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.borderMint,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildSafetyNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionIcon() {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.13),
        shape: BoxShape.circle,
      ),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: AppColors.mint,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.air_rounded,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }

  Widget _buildResultSummary() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your breathing session',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  icon: Icons.loop_rounded,
                  title: 'Rounds',
                  value: '$_selectedRounds',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetric(
                  icon: Icons.timer_outlined,
                  title: 'Pattern',
                  value: '4 × 4',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite_border_rounded,
                  color: AppColors.mint,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Settledness: $_beforeLevel → $_afterLevel / 5',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

  Widget _buildMetric({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.mint,
            size: 22,
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.spa_rounded,
                color: AppColors.mint,
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                'A small reminder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'You do not have to make your mind completely '
                'quiet. Sometimes giving your attention one '
                'simple rhythm is enough for a pause.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // RESTART
  // ------------------------------------------------------------

  void _restartExercise() {
    _timer?.cancel();
    _breathingController.stop();
    _breathingController.reset();

    setState(() {
      _selectedRounds = 4;
      _currentRound = 1;
      _phaseIndex = 0;
      _secondsRemaining = 4;
      _beforeLevel = 3;
      _afterLevel = 3;
      _sessionStarted = false;
      _sessionComplete = false;
    });
  }

  // ------------------------------------------------------------
  // LEAVE DIALOG
  // ------------------------------------------------------------

  void _showLeaveDialog() {
    _timer?.cancel();
    _breathingController.stop();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Leave breathing exercise?',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Your current breathing session will be lost.',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _startPhaseAnimation();
                _startTimer();
              },
              child: const Text(
                'Stay',
                style: TextStyle(
                  color: AppColors.mint,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text(
                'Leave',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // SAFETY
  // ------------------------------------------------------------

  Widget _buildSafetyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.mint,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Breathe comfortably and do not force your breath. '
                  'If you feel dizzy, uncomfortable, or unwell, stop '
                  'the exercise and return to your normal breathing. '
                  'MindMate exercises are general wellbeing tools and '
                  'are not a substitute for professional care.',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CARD STYLE
  // ------------------------------------------------------------

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.borderMint,
      ),
    );
  }
}

// ------------------------------------------------------------
// BREATHING BOX PAINTER
// ------------------------------------------------------------

class _BoxBreathingPainter extends CustomPainter {
  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(
      22,
      22,
      size.width - 44,
      size.height - 44,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(25),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}