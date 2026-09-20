import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class DigitalDetoxScreen extends StatefulWidget {
  const DigitalDetoxScreen({super.key});

  @override
  State<DigitalDetoxScreen> createState() => _DigitalDetoxScreenState();
}

class _DigitalDetoxScreenState extends State<DigitalDetoxScreen> {
  Timer? _timer;

  int _currentStep = 0;

  int? _screenTimeFeeling;
  String? _mainDistraction;
  int _selectedMinutes = 5;

  int _secondsRemaining = 300;

  bool _challengeStarted = false;
  bool _challengeComplete = false;

  final List<String> _distractions = [
    'Social media',
    'Messages',
    'Videos',
    'Gaming',
    'Constant checking',
    'Something else',
  ];

  final List<int> _durations = [2, 5, 10, 15];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_challengeComplete) {
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
                    _buildProgress(),
                    const SizedBox(height: 22),
                    _buildCurrentStep(),
                    const SizedBox(height: 22),
                    _buildDetoxTip(),
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

  // ============================================================
  // HEADER
  // ============================================================

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
                if (_challengeStarted) {
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
                  'Digital Detox',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Give your attention some breathing room.',
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
              'OFFLINE',
              style: TextStyle(
                color: AppColors.mint,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

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
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
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
                  Icons.phonelink_erase_rounded,
                  color: AppColors.mint,
                  size: 31,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Put the phone down.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This is not about quitting technology. '
                          'It is about choosing a short moment where '
                          'your attention belongs to you.',
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
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgress() {
    return Row(
      children: List.generate(
        3,
            (index) {
          final active = index <= _currentStep;

          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(
                right: index == 2 ? 0 : 6,
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

  // ============================================================
  // CURRENT STEP
  // ============================================================

  Widget _buildCurrentStep() {
    if (_currentStep == 0) {
      return _buildCheckInStep();
    }

    if (_currentStep == 1) {
      return _buildSetupStep();
    }

    return _buildChallengeStep();
  }

  // ============================================================
  // STEP 1 — CHECK IN
  // ============================================================

  Widget _buildCheckInStep() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepLabel('STEP 1 OF 3'),
          const SizedBox(height: 7),
          const Text(
            'How has your phone been feeling lately?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'There is no right answer. Choose the option '
                'that feels closest to your experience.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'I feel...',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeelingOption(
            value: 1,
            icon: Icons.sentiment_satisfied_alt_rounded,
            title: 'In control',
            subtitle: 'I use my phone intentionally.',
          ),
          _buildFeelingOption(
            value: 2,
            icon: Icons.sentiment_neutral_rounded,
            title: 'A little distracted',
            subtitle: 'I check it more than I need to.',
          ),
          _buildFeelingOption(
            value: 3,
            icon: Icons.sentiment_dissatisfied_rounded,
            title: 'Pulled toward it',
            subtitle: 'It is difficult to leave it alone.',
          ),
          _buildFeelingOption(
            value: 4,
            icon: Icons.sync_problem_rounded,
            title: 'Constantly checking',
            subtitle: 'I reach for it almost automatically.',
          ),
          if (_screenTimeFeeling == null)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Please choose how you feel before continuing.',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 18),
          _primaryButton(
            text: 'Continue',
            icon: Icons.arrow_forward_rounded,
            enabled: _screenTimeFeeling != null,
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeelingOption({
    required int value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _screenTimeFeeling == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _screenTimeFeeling = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightMint
              : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.mint
                : AppColors.borderMint,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.mint.withValues(alpha: 0.14)
                    : Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: selected
                    ? AppColors.mint
                    : AppColors.navy.withValues(alpha: 0.55),
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
                    title,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? AppColors.mint
                  : AppColors.borderMint,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STEP 2 — DETOX SETUP
  // ============================================================

  Widget _buildSetupStep() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepLabel('STEP 2 OF 3'),
          const SizedBox(height: 7),
          const Text(
            'What usually pulls you back?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pick the main reason you want a little distance '
                'from your screen today.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 19),
          Wrap(
            spacing: 8,
            runSpacing: 9,
            children: _distractions.map(
                  (item) {
                final selected = _mainDistraction == item;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _mainDistraction = item;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.mint
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected
                            ? AppColors.mint
                            : AppColors.borderMint,
                      ),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.navy,
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          if (_mainDistraction == null)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Choose what you want to step away from.',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 23),
          const Text(
            'CHOOSE YOUR DETOX WINDOW',
            style: TextStyle(
              color: AppColors.mint,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: _durations.map(
                  (minutes) {
                final selected = _selectedMinutes == minutes;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: minutes == _durations.last ? 0 : 7,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMinutes = minutes;
                          _secondsRemaining = minutes * 60;
                        });
                      },
                      child: AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 180),
                        height: 51,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.navy
                              : AppColors.lightMint,
                          borderRadius:
                          BorderRadius.circular(15),
                          border: Border.all(
                            color: selected
                                ? AppColors.navy
                                : AppColors.borderMint,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$minutes min',
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.navy,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 22),
          _primaryButton(
            text: 'Set My Detox',
            icon: Icons.arrow_forward_rounded,
            enabled: _mainDistraction != null,
            onPressed: () {
              setState(() {
                _currentStep = 2;
                _secondsRemaining = _selectedMinutes * 60;
              });
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 3 — CHALLENGE
  // ============================================================

  Widget _buildChallengeStep() {
    return _whiteCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _stepLabel('STEP 3 OF 3'),
          const SizedBox(height: 9),
          const Text(
            'Phone down. Life on.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _challengeStarted
                ? 'Stay away from your phone until the timer finishes.'
                : 'Place your phone somewhere out of reach, then start your detox.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          _buildPhoneVisual(),
          const SizedBox(height: 22),
          if (!_challengeStarted)
            _buildStartChallenge()
          else
            _buildActiveChallenge(),
        ],
      ),
    );
  }

  Widget _buildPhoneVisual() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightMint,
          ),
        ),
        Container(
          width: 105,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.16),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 10,
                child: Container(
                  width: 30,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_off_rounded,
                  color: AppColors.mint,
                  size: 27,
                ),
              ),
              Positioned(
                bottom: 9,
                child: Container(
                  width: 22,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 14,
          top: 24,
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppColors.mint,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.background,
                width: 4,
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartChallenge() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.place_rounded,
                color: AppColors.mint,
                size: 21,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Put the phone face-down or somewhere you cannot casually reach it.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        _primaryButton(
          text: 'Start $_selectedMinutes Minute Detox',
          icon: Icons.timer_outlined,
          enabled: true,
          onPressed: _startChallenge,
        ),
      ],
    );
  }

  Widget _buildActiveChallenge() {
    final totalSeconds = _selectedMinutes * 60;
    final progress =
        1 - (_secondsRemaining / totalSeconds);

    return Column(
      children: [
        Text(
          _formatTime(_secondsRemaining),
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 42,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'YOUR PHONE IS OFF DUTY',
          style: TextStyle(
            color: AppColors.mint,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.borderMint,
            valueColor:
            const AlwaysStoppedAnimation<Color>(
              AppColors.mint,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.visibility_off_rounded,
                color: AppColors.mint,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _detoxMessage(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TIMER
  // ============================================================

  void _startChallenge() {
    setState(() {
      _challengeStarted = true;
      _secondsRemaining = _selectedMinutes * 60;
    });

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining <= 1) {
          timer.cancel();

          setState(() {
            _secondsRemaining = 0;
          });

          _finishChallenge();
          return;
        }

        setState(() {
          _secondsRemaining--;
        });
      },
    );
  }

  void _finishChallenge() {
    _timer?.cancel();

    setState(() {
      _challengeStarted = false;
      _challengeComplete = true;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remaining.toString().padLeft(2, '0')}';
  }

  String _detoxMessage() {
    if (_secondsRemaining > (_selectedMinutes * 60) * 0.75) {
      return 'The urge to check may appear. You do not have to act on it.';
    }

    if (_secondsRemaining > (_selectedMinutes * 60) * 0.45) {
      return 'Let your attention move somewhere else — your surroundings, your breath, or your thoughts.';
    }

    if (_secondsRemaining > (_selectedMinutes * 60) * 0.20) {
      return 'You are creating a small space between the impulse and the action.';
    }

    return 'Almost there. Stay with the moment you chose for yourself.';
  }

  // ============================================================
  // DETOX TIP
  // ============================================================

  Widget _buildDetoxTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
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
            Icons.lightbulb_outline_rounded,
            color: AppColors.mint,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'A digital detox does not have to mean avoiding '
                  'technology completely. Even a few intentional '
                  'minutes without checking can help you notice '
                  'where your attention naturally goes.',
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

  // ============================================================
  // RESULT SCREEN
  // ============================================================

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
                      'Detox Complete',
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
                      'You chose your attention.',
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
                      'For a few minutes, your phone waited '
                          'while you stayed with the moment.',
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
                          'Take Another Detox',
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
      width: 94,
      height: 94,
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
          Icons.phonelink_erase_rounded,
          color: Colors.white,
          size: 43,
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
            'Your detox session',
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
                  icon: Icons.timer_outlined,
                  title: 'Time',
                  value: '$_selectedMinutes min',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetric(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Completed',
                  value: '100%',
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
                  Icons.block_rounded,
                  color: AppColors.mint,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your main distraction: '
                        '${_mainDistraction ?? 'Not selected'}',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.self_improvement_rounded,
                color: AppColors.mint,
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                'Take the idea with you',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'The goal is not to avoid your phone forever. '
                'It is to notice that you can pause before '
                'automatically reaching for it.',
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

  // ============================================================
  // RESTART
  // ============================================================

  void _restartExercise() {
    _timer?.cancel();

    setState(() {
      _currentStep = 0;
      _screenTimeFeeling = null;
      _mainDistraction = null;
      _selectedMinutes = 5;
      _secondsRemaining = 300;
      _challengeStarted = false;
      _challengeComplete = false;
    });
  }

  // ============================================================
  // LEAVE
  // ============================================================

  void _showLeaveDialog() {
    _timer?.cancel();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Leave digital detox?',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Your current detox progress will be lost.',
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

                if (_challengeStarted) {
                  _startChallengeTimer();
                }
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

  void _startChallengeTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining <= 1) {
          timer.cancel();
          _finishChallenge();
          return;
        }

        setState(() {
          _secondsRemaining--;
        });
      },
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Widget _stepLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.mint,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _whiteCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: child,
    );
  }

  Widget _primaryButton({
    required String text,
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 51,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.borderMint,
          disabledForegroundColor: Colors.grey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

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
              'Digital detox is an optional wellbeing exercise. '
                  'Keep your phone available if you need it for '
                  'safety, work, caregiving, accessibility, or '
                  'important communication.',
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
}