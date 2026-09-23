import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class GroundingScreen extends StatefulWidget {
  const GroundingScreen({super.key});

  @override
  State<GroundingScreen> createState() => _GroundingScreenState();
}

class _GroundingScreenState extends State<GroundingScreen>
    with SingleTickerProviderStateMixin {
  int _currentSense = 0;

  int _groundingBefore = 3;
  int _groundingAfter = 3;

  bool _sessionStarted = false;
  bool _sessionComplete = false;

  Timer? _timer;
  int _secondsRemaining = 30;

  final List<String> _senseNames = [
    'See',
    'Touch',
    'Hear',
    'Smell',
    'Notice',
  ];

  final List<IconData> _senseIcons = [
    Icons.visibility_rounded,
    Icons.pan_tool_alt_rounded,
    Icons.hearing_rounded,
    Icons.air_rounded,
    Icons.self_improvement_rounded,
  ];

  final List<String> _senseTitles = [
    'Look around you',
    'Feel what is here',
    'Listen closely',
    'Notice the air',
    'Notice yourself',
  ];

  final List<String> _senseDescriptions = [
    'Slowly look around and find three ordinary things you can see.',
    'Notice the physical sensations around you without changing them.',
    'Pause and identify two sounds — one nearby and one farther away.',
    'Notice one scent or simply pay attention to the air around you.',
    'Notice your breathing, posture, feet, and the space supporting you.',
  ];

  final List<String> _sensePrompts = [
    'Find 3 things you can see.\n'
        'Notice their shape, colour, texture, or position.',

    'Find 2 things you can physically feel.\n'
        'For example: your feet on the floor or your hands touching something.',

    'Find 2 sounds.\n'
        'Notice which one is closest and which one is farther away.',

    'Find 1 smell or sensation in the air.\n'
        'There is no need to identify it perfectly.',

    'Take one slow breath.\n'
        'Notice your body being supported by the chair, floor, or bed.',
  ];

  final List<String?> _responses = [
    null,
    null,
    null,
    null,
    null,
  ];

  final List<String> _responseOptions = [
    'I noticed something',
    'I found it easily',
    'It took some time',
    'I am not sure',
  ];

  @override
  void dispose() {
    _timer?.cancel();
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
                    _buildIntroCard(),

                    const SizedBox(height: 24),

                    _buildGroundingCheck(),

                    const SizedBox(height: 24),

                    _buildSenseProgress(),

                    const SizedBox(height: 24),

                    if (!_sessionStarted)
                      _buildStartCard()
                    else
                      _buildCurrentSense(),

                    const SizedBox(height: 24),

                    _buildGroundingTip(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (_sessionStarted) {
                    _showLeaveDialog();
                  } else {
                    Navigator.pop(context);
                  }
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
                      'Grounding',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Come back to the moment you are in.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              width: 40,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
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
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.explore_rounded,
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
                  'Find your way back to now.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Grounding uses your senses to shift attention '
                      'away from mental noise and toward what is '
                      'happening around you right now.',
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

  Widget _buildGroundingCheck() {
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

          const SizedBox(height: 6),

          const Text(
            'How grounded do you feel right now?',
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
                final level = index + 1;
                final selected =
                    _groundingBefore == level;

                return GestureDetector(
                  onTap: _sessionStarted
                      ? null
                      : () {
                    setState(() {
                      _groundingBefore = level;
                    });
                  },
                  child: AnimatedContainer(
                    duration:
                    const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.mint
                          : AppColors.lightMint,
                      borderRadius:
                      BorderRadius.circular(15),
                      border: Border.all(
                        color: selected
                            ? AppColors.mint
                            : AppColors.borderMint,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$level',
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
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Disconnected',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
              Text(
                'Very grounded',
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

  Widget _buildSenseProgress() {
    return Column(
      children: [
        Row(
          children: List.generate(
            5,
                (index) {
              final completed =
                  _responses[index] != null;
              final current =
                  _sessionStarted &&
                      index == _currentSense;

              return Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(
                    right: index == 4 ? 0 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: completed || current
                        ? AppColors.mint
                        : AppColors.borderMint,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 13),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: List.generate(
            5,
                (index) {
              return Text(
                _senseNames[index],
                style: TextStyle(
                  color: index == _currentSense &&
                      _sessionStarted
                      ? AppColors.mint
                      : Colors.grey,
                  fontSize: 10,
                  fontWeight:
                  index == _currentSense &&
                      _sessionStarted
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(24),
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
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: AppColors.mint,
              size: 36,
            ),
          ),

          const SizedBox(height: 17),

          const Text(
            'Ready to ground yourself?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'We will move through five simple sensory '
                'check-ins. There is nothing you need to do perfectly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _startGrounding,
              icon: const Icon(
                Icons.play_arrow_rounded,
              ),
              label: const Text(
                'Begin Grounding',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
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

  void _startGrounding() {
    setState(() {
      _sessionStarted = true;
      _currentSense = 0;
      _secondsRemaining = 30;
    });

    _startTimer();
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

        if (_secondsRemaining <= 1) {
          timer.cancel();

          setState(() {
            _secondsRemaining = 0;
          });

          return;
        }

        setState(() {
          _secondsRemaining--;
        });
      },
    );
  }

  Widget _buildCurrentSense() {
    final icon = _senseIcons[_currentSense];
    final title = _senseTitles[_currentSense];
    final description =
    _senseDescriptions[_currentSense];
    final prompt = _sensePrompts[_currentSense];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration:
                const Duration(milliseconds: 300),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.mint,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP ${_currentSense + 1} OF 5',
                      style: const TextStyle(
                        color: AppColors.mint,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              _buildTimerCircle(),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            description,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRY THIS',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  prompt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'How did that feel?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 7,
            runSpacing: 8,
            children: _responseOptions.map(
                  (option) {
                final selected =
                    _responses[_currentSense] ==
                        option;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _responses[_currentSense] =
                          option;
                    });
                  },
                  child: AnimatedContainer(
                    duration:
                    const Duration(milliseconds: 180),
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.mint
                          : AppColors.background,
                      borderRadius:
                      BorderRadius.circular(18),
                      border: Border.all(
                        color: selected
                            ? AppColors.mint
                            : AppColors.borderMint,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors.navy,
                        fontSize: 10,
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

          if (_responses[_currentSense] == null)
            Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Text(
                'Choose how the step felt before continuing.',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _responses[_currentSense] ==
                  null
                  ? null
                  : _nextSense,
              icon: Icon(
                _currentSense == 4
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(
                _currentSense == 4
                    ? 'Finish Grounding'
                    : 'Next Sense',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mint,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                AppColors.borderMint,
                disabledForegroundColor: Colors.grey,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCircle() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: _secondsRemaining / 30,
            strokeWidth: 3,
            backgroundColor: AppColors.borderMint,
            valueColor:
            const AlwaysStoppedAnimation<Color>(
              AppColors.mint,
            ),
          ),
          Text(
            '$_secondsRemaining',
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

  void _nextSense() {
    _timer?.cancel();

    if (_currentSense == 4) {
      setState(() {
        _sessionComplete = true;
        _groundingAfter =
            (_groundingBefore + 1).clamp(1, 5);
      });
      return;
    }

    setState(() {
      _currentSense++;
      _secondsRemaining = 30;
    });

    _startTimer();
  }

  Widget _buildGroundingTip() {
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
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.mint,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Grounding is not about making every thought '
                  'disappear. It is about giving your attention '
                  'something real and present to connect with.',
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
                    borderRadius:
                    BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(14),
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
                      'Grounding Complete',
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
                physics:
                const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  30,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.mint
                            .withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.explore_rounded,
                        color: AppColors.mint,
                        size: 48,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'You are back in the moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'You slowed down and gave your senses '
                          'a chance to reconnect you with what is '
                          'happening right now.',
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

                    _buildGroundingReminder(),

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
                          'Ground Again',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.mint,
                          foregroundColor:
                          Colors.white,
                          elevation: 0,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                          textStyle:
                          const TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w800,
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
                            color:
                            AppColors.borderMint,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight:
                            FontWeight.w800,
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
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Your grounding check-in',
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
                  icon: Icons.sensors_rounded,
                  title: 'Before',
                  value:
                  '$_groundingBefore / 5',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetric(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'After',
                  value:
                  '$_groundingAfter / 5',
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
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.mint,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You completed all 5 grounding steps.',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w700,
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
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
              fontWeight:
              FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroundingReminder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius:
        BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
                'Carry this with you',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Text(
            'When your mind feels far away, you can '
                'return to something simple: look around, '
                'feel the ground, listen, breathe, and notice '
                'where you are.',
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

  void _restartExercise() {
    _timer?.cancel();

    setState(() {
      _currentSense = 0;
      _groundingBefore = 3;
      _groundingAfter = 3;
      _sessionStarted = false;
      _sessionComplete = false;
      _secondsRemaining = 30;

      for (int i = 0; i < _responses.length; i++) {
        _responses[i] = null;
      }
    });
  }

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
            'Leave grounding?',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Your current grounding progress will be lost.',
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

  Widget _buildSafetyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightMint.withValues(
          alpha: 0.65,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.mint,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'MindMate exercises are general wellbeing tools '
                  'and are not a substitute for professional mental-health '
                  'care. If you feel unsafe or are in immediate danger, '
                  'seek appropriate emergency or professional support.',
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