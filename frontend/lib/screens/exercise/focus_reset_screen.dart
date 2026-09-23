import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class FocusResetScreen extends StatefulWidget {
  const FocusResetScreen({super.key});

  @override
  State<FocusResetScreen> createState() => _FocusResetScreenState();
}

class _FocusResetScreenState extends State<FocusResetScreen> {
  final _taskController = TextEditingController();
  final _nextStepController = TextEditingController();
  final _distractionController = TextEditingController();

  Timer? _focusTimer;

  int _selectedMinutes = 2;
  int _secondsRemaining = 120;
  int _totalSeconds = 120;

  int _beforeFocus = 3;
  int _afterFocus = 3;

  bool _isRunning = false;
  bool _sessionComplete = false;

  String? _selectedDistraction;

  final List<String> _distractions = [];

  final List<int> _focusDurations = [
    1,
    2,
    5,
    10,
    15,
    25,
  ];

  final List<String> _distractionReasons = [
    'Too many thoughts',
    'Phone or social media',
    'Study or work pressure',
    'Stress or worry',
    'Tiredness',
    'I feel mentally scattered',
  ];

  @override
  void dispose() {
    _focusTimer?.cancel();
    _taskController.dispose();
    _nextStepController.dispose();
    _distractionController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  double get _progress {
    if (_totalSeconds == 0) {
      return 0;
    }

    return 1 - (_secondsRemaining / _totalSeconds);
  }

  void _selectFocusDuration(int minutes) {
    if (_isRunning) {
      return;
    }

    setState(() {
      _selectedMinutes = minutes;
      _totalSeconds = minutes * 60;
      _secondsRemaining = minutes * 60;
      _sessionComplete = false;
    });
  }

  void _startFocusSprint() {
    FocusScope.of(context).unfocus();

    if (_taskController.text.trim().isEmpty ||
        _nextStepController.text.trim().isEmpty) {
      _showMessage(
        'Choose one task and write one small next step first.',
      );
      return;
    }

    if (_isRunning) {
      return;
    }

    final durationInSeconds = _selectedMinutes * 60;

    setState(() {
      _isRunning = true;
      _sessionComplete = false;
      _totalSeconds = durationInSeconds;
      _secondsRemaining = durationInSeconds;
    });

    _focusTimer?.cancel();

    _focusTimer = Timer.periodic(
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
            _isRunning = false;
            _sessionComplete = true;
          });

          _showCompletionMessage();
          return;
        }

        setState(() {
          _secondsRemaining--;
        });
      },
    );
  }

  void _restartSprint() {
    _focusTimer?.cancel();

    final durationInSeconds = _selectedMinutes * 60;

    setState(() {
      _totalSeconds = durationInSeconds;
      _secondsRemaining = durationInSeconds;
      _isRunning = false;
      _sessionComplete = false;
      _distractions.clear();
    });
  }

  void _addDistraction() {
    final distraction = _distractionController.text.trim();

    if (distraction.isEmpty) {
      return;
    }

    setState(() {
      _distractions.add(distraction);
      _distractionController.clear();
    });
  }

  void _removeDistraction(int index) {
    setState(() {
      _distractions.removeAt(index);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
      ),
    );
  }

  void _showCompletionMessage() {
    Future.delayed(
      const Duration(milliseconds: 250),
          () {
        if (!mounted) {
          return;
        }

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Focus sprint complete',
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: Text(
                'You gave one task your attention for '
                    '$_selectedMinutes minute${_selectedMinutes == 1 ? '' : 's'}. '
                    'Now take a moment to notice how you feel.',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Continue',
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
      },
    );
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
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroCard(),

                    const SizedBox(height: 24),

                    _buildProgressIndicator(),

                    const SizedBox(height: 26),

                    _buildSectionTitle(
                      '1. Check in',
                      'Start by noticing where your attention is right now.',
                    ),

                    const SizedBox(height: 12),

                    _buildFocusLevelCard(),

                    const SizedBox(height: 26),

                    _buildSectionTitle(
                      '2. Choose one thing',
                      'Make the next step small enough to begin immediately.',
                    ),

                    const SizedBox(height: 12),

                    _buildTaskCard(),

                    const SizedBox(height: 26),

                    _buildSectionTitle(
                      '3. Focus sprint',
                      'Choose how long you want to stay with one task.',
                    ),

                    const SizedBox(height: 12),

                    _buildFocusSprintCard(),

                    const SizedBox(height: 20),

                    _buildDistractionParkingCard(),

                    if (_sessionComplete) ...[
                      const SizedBox(height: 26),
                      _buildAfterFocusCard(),
                      const SizedBox(height: 20),
                      _buildCompletionCard(),
                    ],

                    const SizedBox(height: 26),

                    _buildReminderCard(),

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
                  if (_isRunning) {
                    _showMessage(
                      'Finish or restart the focus sprint before leaving.',
                    );
                    return;
                  }

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
                      'Focus Reset',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Clear the noise. Return to one thing.',
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightMint,
            AppColors.background,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.center_focus_strong_rounded,
              color: AppColors.mint,
              size: 29,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bring your attention back.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'When everything feels important, focusing on one '
                      'small action can make starting feel easier.',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
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

  Widget _buildProgressIndicator() {
    final int currentStep;

    if (_sessionComplete) {
      currentStep = 3;
    } else if (_isRunning) {
      currentStep = 2;
    } else if (_taskController.text.trim().isNotEmpty) {
      currentStep = 1;
    } else {
      currentStep = 0;
    }

    return Row(
      children: [
        _buildProgressStep(
          number: '1',
          label: 'Prepare',
          active: currentStep >= 0,
        ),

        _buildProgressLine(
          active: currentStep >= 1,
        ),

        _buildProgressStep(
          number: '2',
          label: 'Focus',
          active: currentStep >= 2,
        ),

        _buildProgressLine(
          active: currentStep >= 3,
        ),

        _buildProgressStep(
          number: '3',
          label: 'Check',
          active: currentStep >= 3,
        ),
      ],
    );
  }

  Widget _buildProgressStep({
    required String number,
    required String label,
    required bool active,
  }) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: active
                ? AppColors.mint
                : AppColors.lightMint,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          label,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine({
    required bool active,
  }) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(
          left: 6,
          right: 6,
          bottom: 19,
        ),
        color: active
            ? AppColors.mint
            : AppColors.borderMint,
      ),
    );
  }

  Widget _buildSectionTitle(
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
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFocusLevelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How focused do you feel right now?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
                  (index) {
                final level = index + 1;
                final selected = _beforeFocus == level;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _beforeFocus = level;
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
                      borderRadius: BorderRadius.circular(14),
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

          const SizedBox(height: 10),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Very scattered',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              Text(
                'Very focused',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'What is pulling your attention?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 11),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _distractionReasons.map(
                  (reason) {
                final selected = _selectedDistraction == reason;

                return ChoiceChip(
                  label: Text(reason),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedDistraction = reason;
                    });
                  },
                  selectedColor: AppColors.mint.withValues(
                    alpha: 0.18,
                  ),
                  backgroundColor: AppColors.background,
                  side: BorderSide(
                    color: selected
                        ? AppColors.mint
                        : AppColors.borderMint,
                  ),
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.navy
                        : AppColors.textDark,
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(
            'What is the ONE thing you want to focus on?',
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _taskController,
            enabled: !_isRunning,
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              hintText: 'e.g. Review one lecture topic',
              prefixIcon: Icons.task_alt_rounded,
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),

          const SizedBox(height: 10),

          _buildFieldLabel(
            'What is the smallest next action?',
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _nextStepController,
            enabled: !_isRunning,
            maxLength: 100,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              hintText: 'e.g. Read the first two pages',
              prefixIcon: Icons.play_arrow_rounded,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Keep it specific. You are not finishing everything — '
                'you are simply starting.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusSprintCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Text(
            '$_selectedMinutes-MINUTE FOCUS SPRINT',
            style: const TextStyle(
              color: AppColors.mint,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 16),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose your focus time',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _focusDurations.map(
                  (minutes) {
                final isSelected =
                    _selectedMinutes == minutes;

                return GestureDetector(
                  onTap: _isRunning
                      ? null
                      : () {
                    _selectFocusDuration(minutes);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.mint
                          : Colors.white.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.mint
                            : Colors.white.withValues(
                          alpha: 0.20,
                        ),
                      ),
                    ),
                    child: Text(
                      '$minutes min',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),

          const SizedBox(height: 22),

          Text(
            _formattedTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(
                alpha: 0.12,
              ),
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            _isRunning
                ? 'Stay with your chosen action. '
                'If another thought appears, park it below.'
                : _sessionComplete
                ? 'Sprint complete. Take a moment to check in.'
                : 'For the next $_selectedMinutes minute'
                '${_selectedMinutes == 1 ? '' : 's'}, '
                'give one thing your full attention.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          if (!_sessionComplete)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                _isRunning ? null : _startFocusSprint,
                icon: Icon(
                  _isRunning
                      ? Icons.hourglass_top_rounded
                      : Icons.play_arrow_rounded,
                ),
                label: Text(
                  _isRunning
                      ? 'Focus Sprint Running'
                      : 'Start Focus Sprint',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  AppColors.mint.withValues(alpha: 0.55),
                  disabledForegroundColor:
                  Colors.white.withValues(alpha: 0.8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

          if (_sessionComplete)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _restartSprint,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.mint,
                ),
                label: const Text(
                  'Try Another Sprint',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.mint.withValues(
                      alpha: 0.8,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDistractionParkingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  color: AppColors.mint,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distraction Parking',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Notice it. Park it. Return to your task.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _distractionController,
                  decoration: _inputDecoration(
                    hintText: 'Something distracting you?',
                    prefixIcon: Icons.push_pin_outlined,
                  ),
                  onSubmitted: (_) {
                    _addDistraction();
                  },
                ),
              ),

              const SizedBox(width: 8),

              Material(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _addDistraction,
                  child: const SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_distractions.isNotEmpty) ...[
            const SizedBox(height: 14),

            ...List.generate(
              _distractions.length,
                  (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bookmark_border_rounded,
                        size: 17,
                        color: AppColors.mint,
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          _distractions[index],
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          _removeDistraction(index);
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          size: 17,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAfterFocusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '4. Check in again',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'There is no right answer. Just notice your current state.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'How focused do you feel now?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 13),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
                  (index) {
                final level = index + 1;
                final selected = _afterFocus == level;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _afterFocus = level;
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
                      borderRadius: BorderRadius.circular(14),
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
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Very scattered',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
              Text(
                'Very focused',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Focus reset complete',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'You practiced returning your attention to one '
                'clear next step. That is the purpose of this reset.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildResultBox(
                  title: 'Before',
                  value: '$_beforeFocus / 5',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildResultBox(
                  title: 'After',
                  value: '$_afterFocus / 5',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildResultBox(
                  title: 'Sprint',
                  value: '$_selectedMinutes min',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultBox({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard() {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.mint,
            size: 24,
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A useful reminder',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Focus is not about never getting distracted. '
                      'It is about noticing when your attention moves '
                      'and gently returning it.',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.mint,
            size: 20,
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'MindMate exercises are general wellbeing tools and '
                  'are not a substitute for professional mental-health care. '
                  'If you feel unsafe or are in immediate danger, seek '
                  'appropriate emergency or professional support.',
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

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: AppColors.mint,
        size: 20,
      ),
      filled: true,
      fillColor: AppColors.background,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.borderMint,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.borderMint,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.mint,
          width: 1.5,
        ),
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