import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class StressReleaseScreen extends StatefulWidget {
  const StressReleaseScreen({super.key});

  @override
  State<StressReleaseScreen> createState() => _StressReleaseScreenState();
}

class _StressReleaseScreenState extends State<StressReleaseScreen> {
  // ------------------------------------------------------------
  // STEP CONTROL
  // ------------------------------------------------------------

  int _step = 0;
  bool _isCompleted = false;

  // ------------------------------------------------------------
  // STEP 1 — WHAT IS TAKING UP SPACE
  // ------------------------------------------------------------

  String? _selectedStressArea;
  String? _stressAreaError;

  final List<Map<String, dynamic>> _stressAreas = [
    {
      'title': 'Exams',
      'emoji': '📚',
    },
    {
      'title': 'Work',
      'emoji': '💼',
    },
    {
      'title': 'Relationships',
      'emoji': '💬',
    },
    {
      'title': 'Money',
      'emoji': '💰',
    },
    {
      'title': 'Family',
      'emoji': '🏠',
    },
    {
      'title': 'Myself',
      'emoji': '🧠',
    },
    {
      'title': 'Something else',
      'emoji': '✨',
    },
  ];

  // ------------------------------------------------------------
  // STEP 2 — STRESS DUMP
  // ------------------------------------------------------------

  final TextEditingController _stressDumpController =
  TextEditingController();

  String? _stressDumpError;

  // ------------------------------------------------------------
  // STEP 3 — CONTROL
  // ------------------------------------------------------------

  String? _selectedControl;
  String? _controlError;

  final List<Map<String, dynamic>> _controlOptions = [
    {
      'title': 'I can do something about it',
      'subtitle': 'There is something I can take action on.',
      'icon': Icons.touch_app_outlined,
    },
    {
      'title': 'I can do something later',
      'subtitle': 'It matters, but it does not need attention right now.',
      'icon': Icons.schedule_outlined,
    },
    {
      'title': 'I can’t control this',
      'subtitle': 'I can choose how I respond to it.',
      'icon': Icons.cloud_off_outlined,
    },
  ];

  // ------------------------------------------------------------
  // STEP 4 — ONE SMALL THING
  // ------------------------------------------------------------

  String? _selectedNextStep;
  String? _nextStepError;

  final List<Map<String, dynamic>> _nextSteps = [
    {
      'title': 'Take a 5-minute break',
      'icon': Icons.coffee_outlined,
    },
    {
      'title': 'Do one small task',
      'icon': Icons.task_alt_outlined,
    },
    {
      'title': 'Ask someone for help',
      'icon': Icons.people_outline,
    },
    {
      'title': 'Write it down for tomorrow',
      'icon': Icons.edit_note_outlined,
    },
    {
      'title': 'Nothing right now — rest',
      'icon': Icons.self_improvement_outlined,
    },
  ];

  // ------------------------------------------------------------
  // STEP 5 — RELEASE
  // ------------------------------------------------------------

  bool _isHolding = false;
  double _releaseProgress = 0.0;
  Timer? _releaseTimer;

  bool _releaseCompleted = false;

  @override
  void dispose() {
    _stressDumpController.dispose();
    _releaseTimer?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------
  // NAVIGATION
  // ------------------------------------------------------------

  void _goBack() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _step--;
    });
  }

  void _goNext() {
    FocusScope.of(context).unfocus();

    if (!_validateCurrentStep()) {
      return;
    }

    setState(() {
      _step++;
    });
  }

  bool _validateCurrentStep() {
    setState(() {
      _stressAreaError = null;
      _stressDumpError = null;
      _controlError = null;
      _nextStepError = null;
    });

    switch (_step) {
      case 0:
        if (_selectedStressArea == null) {
          setState(() {
            _stressAreaError = 'Please choose what is taking up space right now.';
          });
          return false;
        }
        return true;

      case 1:
        final text = _stressDumpController.text.trim();

        if (text.isEmpty) {
          setState(() {
            _stressDumpError =
            'Please write something that has been bothering you.';
          });
          return false;
        }

        if (text.length < 5) {
          setState(() {
            _stressDumpError =
            'Please write a little more so you can get it out of your head.';
          });
          return false;
        }

        return true;

      case 2:
        if (_selectedControl == null) {
          setState(() {
            _controlError =
            'Please choose the option that feels closest to you.';
          });
          return false;
        }
        return true;

      case 3:
        if (_selectedNextStep == null) {
          setState(() {
            _nextStepError = 'Please choose one small next step.';
          });
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  // ------------------------------------------------------------
  // RELEASE HOLD INTERACTION
  // ------------------------------------------------------------

  void _startRelease() {
    if (_releaseCompleted) return;

    setState(() {
      _isHolding = true;
      _releaseProgress = 0.0;
    });

    _releaseTimer?.cancel();

    const totalDuration = Duration(milliseconds: 2200);
    const tickDuration = Duration(milliseconds: 50);

    final totalTicks =
        totalDuration.inMilliseconds ~/ tickDuration.inMilliseconds;

    int currentTick = 0;

    _releaseTimer = Timer.periodic(tickDuration, (timer) {
      currentTick++;

      final progress = currentTick / totalTicks;

      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _releaseProgress = progress.clamp(0.0, 1.0);
      });

      if (currentTick >= totalTicks) {
        timer.cancel();

        setState(() {
          _isHolding = false;
          _releaseProgress = 1.0;
          _releaseCompleted = true;
        });
      }
    });
  }

  void _stopRelease() {
    if (_releaseCompleted) return;

    _releaseTimer?.cancel();

    setState(() {
      _isHolding = false;
      _releaseProgress = 0.0;
    });
  }

  void _finishExercise() {
    if (!_releaseCompleted) return;

    setState(() {
      _isCompleted = true;
    });
  }

  void _startAgain() {
    _releaseTimer?.cancel();

    setState(() {
      _step = 0;
      _isCompleted = false;

      _selectedStressArea = null;
      _stressAreaError = null;

      _stressDumpController.clear();
      _stressDumpError = null;

      _selectedControl = null;
      _controlError = null;

      _selectedNextStep = null;
      _nextStepError = null;

      _isHolding = false;
      _releaseProgress = 0.0;
      _releaseCompleted = false;
    });
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildCompletionPage();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStep(),
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

  // ------------------------------------------------------------
// HEADER
// ------------------------------------------------------------

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
                onTap: _goBack,
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
                child: Text(
                  'Stress Release',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
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

  // ------------------------------------------------------------
  // PROGRESS
  // ------------------------------------------------------------

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
      child: Row(
        children: List.generate(
          5,
              (index) {
            final active = index <= _step;

            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(
                  right: index == 4 ? 0 : 5,
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
      ),
    );
  }

  // ------------------------------------------------------------
  // CURRENT STEP
  // ------------------------------------------------------------

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildStressAreaStep();

      case 1:
        return _buildStressDumpStep();

      case 2:
        return _buildControlStep();

      case 3:
        return _buildNextStepSelection();

      case 4:
        return _buildReleaseStep();

      default:
        return const SizedBox.shrink();
    }
  }

  // ------------------------------------------------------------
  // STEP 1 — STRESS AREA
  // ------------------------------------------------------------

  Widget _buildStressAreaStep() {
    return SingleChildScrollView(
      key: const ValueKey('stress-area'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepNumber('01'),
          const SizedBox(height: 12),

          const Text(
            'What’s taking up space right now?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'You don’t have to explain everything. Just start with what feels closest.',
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.65),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _stressAreas.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.65,
            ),
            itemBuilder: (context, index) {
              final item = _stressAreas[index];
              final selected =
                  _selectedStressArea == item['title'];

              return _buildChoiceCard(
                title: item['title'],
                emoji: item['emoji'],
                selected: selected,
                onTap: () {
                  setState(() {
                    _selectedStressArea = item['title'];
                    _stressAreaError = null;
                  });
                },
              );
            },
          ),

          if (_stressAreaError != null) ...[
            const SizedBox(height: 12),
            _buildInlineError(_stressAreaError!),
          ],

          const SizedBox(height: 28),

          _buildBottomButton(
            text: 'Continue',
            onPressed: _goNext,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // STEP 2 — STRESS DUMP
  // ------------------------------------------------------------

  Widget _buildStressDumpStep() {
    return SingleChildScrollView(
      key: const ValueKey('stress-dump'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepNumber('02'),
          const SizedBox(height: 12),

          const Text(
            'Stress Dump',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Write everything that’s bothering you. Don’t organize it. Don’t make it perfect.',
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.65),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _stressDumpError != null
                    ? Colors.red.shade300
                    : AppColors.borderMint,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextField(
              controller: _stressDumpController,
              minLines: 9,
              maxLines: 14,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_stressDumpError != null) {
                  setState(() {
                    _stressDumpError = null;
                  });
                }
              },
              decoration: const InputDecoration(
                hintText:
                'Put it all here...\n\nYou can write about your thoughts, worries, pressure, frustration, or anything else on your mind.',
                hintStyle: TextStyle(
                  color: Color(0xFF9AA5AD),
                  fontSize: 14,
                  height: 1.5,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(18),
              ),
            ),
          ),

          if (_stressDumpError != null) ...[
            const SizedBox(height: 10),
            _buildInlineError(_stressDumpError!),
          ],

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 17,
                color: AppColors.mint,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This exercise is for reflection. Your entry is not sent anywhere in this UI-only version.',
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.55),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          _buildBottomButton(
            text: 'Continue',
            onPressed: _goNext,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // STEP 3 — CONTROL
  // ------------------------------------------------------------

  Widget _buildControlStep() {
    return SingleChildScrollView(
      key: const ValueKey('control'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepNumber('03'),
          const SizedBox(height: 12),

          const Text(
            'What can you actually control?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'You don’t have to solve everything. Just separate what needs your attention from what doesn’t.',
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.65),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 26),

          ..._controlOptions.map(
                (item) {
              final selected =
                  _selectedControl == item['title'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildLargeChoiceCard(
                  title: item['title'],
                  subtitle: item['subtitle'],
                  icon: item['icon'],
                  selected: selected,
                  onTap: () {
                    setState(() {
                      _selectedControl = item['title'];
                      _controlError = null;
                    });
                  },
                ),
              );
            },
          ),

          if (_controlError != null) ...[
            const SizedBox(height: 2),
            _buildInlineError(_controlError!),
          ],

          const SizedBox(height: 22),

          _buildBottomButton(
            text: 'Continue',
            onPressed: _goNext,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // STEP 4 — NEXT SMALL STEP
  // ------------------------------------------------------------

  Widget _buildNextStepSelection() {
    return SingleChildScrollView(
      key: const ValueKey('next-step'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepNumber('04'),
          const SizedBox(height: 12),

          const Text(
            'Choose one thing.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'What is the smallest helpful thing you could do next?',
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.65),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 26),

          ..._nextSteps.map(
                (item) {
              final selected =
                  _selectedNextStep == item['title'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildLargeChoiceCard(
                  title: item['title'],
                  subtitle: null,
                  icon: item['icon'],
                  selected: selected,
                  onTap: () {
                    setState(() {
                      _selectedNextStep = item['title'];
                      _nextStepError = null;
                    });
                  },
                ),
              );
            },
          ),

          if (_nextStepError != null) ...[
            const SizedBox(height: 2),
            _buildInlineError(_nextStepError!),
          ],

          const SizedBox(height: 22),

          _buildBottomButton(
            text: 'Continue',
            onPressed: _goNext,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // STEP 5 — RELEASE
  // ------------------------------------------------------------

  Widget _buildReleaseStep() {
    return SingleChildScrollView(
      key: const ValueKey('release'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStepNumber('05'),

          const SizedBox(height: 16),

          const Text(
            'Release',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'You’ve put the stress into words.\nNow give yourself permission to put some of it down.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.65),
              fontSize: 15,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 35),

          // Release circle
          GestureDetector(
            onTapDown: (_) => _startRelease(),
            onTapUp: (_) {
              if (!_releaseCompleted) {
                _stopRelease();
              }
            },
            onTapCancel: _stopRelease,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _releaseCompleted
                      ? [
                    AppColors.mint,
                    const Color(0xFF4D9D7A),
                  ]
                      : [
                    AppColors.lightMint,
                    Colors.white,
                  ],
                ),
                border: Border.all(
                  color: _releaseCompleted
                      ? AppColors.mint
                      : AppColors.borderMint,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mint.withOpacity(
                      _isHolding ? 0.28 : 0.10,
                    ),
                    blurRadius: _isHolding ? 30 : 18,
                    spreadRadius: _isHolding ? 5 : 1,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 174,
                    height: 174,
                    child: CircularProgressIndicator(
                      value: _releaseProgress,
                      strokeWidth: 6,
                      backgroundColor:
                      AppColors.borderMint.withOpacity(0.55),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _releaseCompleted
                            ? Colors.white
                            : AppColors.mint,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _releaseCompleted
                            ? Icons.check_rounded
                            : Icons
                            .file_download_done_outlined,
                        size: 36,
                        color: _releaseCompleted
                            ? Colors.white
                            : AppColors.navy,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _releaseCompleted
                            ? 'Released'
                            : 'Hold to Release',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _releaseCompleted
                              ? Colors.white
                              : AppColors.navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _releaseCompleted
                  ? 'You can let the rest wait.'
                  : _isHolding
                  ? 'Keep holding...'
                  : 'Press and hold the circle',
              key: ValueKey(
                '${_releaseCompleted}_$_isHolding',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy.withOpacity(0.65),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 34),

          if (_releaseCompleted) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.borderMint,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.mint.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_outline_rounded,
                      color: AppColors.mint,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You don’t have to carry everything at once. One small step is enough for now.',
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.75),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildBottomButton(
              text: 'Complete Exercise',
              onPressed: _finishExercise,
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // COMPLETION PAGE
  // ------------------------------------------------------------

  Widget _buildCompletionPage() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.borderMint,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.mint,
                    size: 42,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Center(
                child: Text(
                  'Stress Release Complete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'You took a moment to slow down, put your stress into words, and choose what deserves your attention.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy.withOpacity(0.65),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),

              const SizedBox(height: 30),

              _buildResultCard(
                icon: Icons.psychology_outlined,
                title: 'What was taking up space',
                value: _selectedStressArea ?? 'Not selected',
              ),

              const SizedBox(height: 12),

              _buildResultCard(
                icon: Icons.edit_note_outlined,
                title: 'What you wrote',
                value: _stressDumpController.text.trim(),
                multiline: true,
              ),

              const SizedBox(height: 12),

              _buildResultCard(
                icon: Icons.filter_alt_outlined,
                title: 'What you can control',
                value: _selectedControl ?? 'Not selected',
              ),

              const SizedBox(height: 12),

              _buildResultCard(
                icon: Icons.directions_outlined,
                title: 'Your next step',
                value: _selectedNextStep ?? 'Not selected',
              ),

              const SizedBox(height: 26),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.navy,
                      Color(0xFF2D4356),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.favorite_outline_rounded,
                      color: AppColors.mint,
                      size: 30,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'You don’t have to solve everything right now.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You identified one thing you can focus on. That is enough for this moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _startAgain,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(
                      color: AppColors.borderMint,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start Again',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Center(
                child: Text(
                  'MindMate exercises are for reflection and general wellbeing, not diagnosis or treatment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.45),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // RESULT CARD
  // ------------------------------------------------------------

  Widget _buildResultCard({
    required IconData icon,
    required String title,
    required String value,
    bool multiline = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  maxLines: multiline ? 8 : 3,
                  overflow: multiline
                      ? TextOverflow.fade
                      : TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
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
  // SMALL CHOICE CARD
  // ------------------------------------------------------------

  Widget _buildChoiceCard({
    required String title,
    required String emoji,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightMint
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.mint
                : AppColors.borderMint,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 13,
                  fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LARGE CHOICE CARD
  // ------------------------------------------------------------

  Widget _buildLargeChoiceCard({
    required String title,
    required String? subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightMint
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.mint
                : AppColors.borderMint,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.mint.withOpacity(0.15)
                    : AppColors.lightMint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppColors.mint,
                size: 23,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.55),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppColors.mint
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.mint
                      : AppColors.borderMint,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // STEP NUMBER
  // ------------------------------------------------------------

  Widget _buildStepNumber(String number) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'STEP $number',
        style: const TextStyle(
          color: AppColors.mint,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // INLINE ERROR
  // ------------------------------------------------------------

  Widget _buildInlineError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.055),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.red.withOpacity(0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 17,
            color: Colors.red.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM BUTTON
  // ------------------------------------------------------------

  Widget _buildBottomButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}