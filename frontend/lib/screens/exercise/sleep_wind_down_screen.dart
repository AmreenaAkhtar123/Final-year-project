import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SleepWindDownScreen extends StatefulWidget {
  const SleepWindDownScreen({super.key});

  @override
  State<SleepWindDownScreen> createState() => _SleepWindDownScreenState();
}

class _SleepWindDownScreenState extends State<SleepWindDownScreen> {
  // ------------------------------------------------------------
  // FLOW
  // 0 = Welcome
  // 1 = Feeling
  // 2 = Calm Visualization
  // 3 = Release the Day
  // 4 = Bedtime Intention
  // ------------------------------------------------------------

  int _step = 0;
  bool _isCompleted = false;

  // Feeling
  String? _selectedFeeling;
  String? _feelingError;

  final List<Map<String, String>> _feelings = [
    {
      'title': 'Calm',
      'emoji': '😌',
    },
    {
      'title': 'Tired',
      'emoji': '😴',
    },
    {
      'title': 'Restless',
      'emoji': '😵‍💫',
    },
    {
      'title': 'Stressed',
      'emoji': '😣',
    },
    {
      'title': 'Overthinking',
      'emoji': '🧠',
    },
    {
      'title': 'Not sure',
      'emoji': '🤷',
    },
  ];

  // Calm Visualization
  String? _selectedScene;

  bool _visualizationRunning = false;
  bool _visualizationPaused = false;

  int _visualizationRemainingSeconds = 60;

  Timer? _visualizationTimer;

  String? _visualizationError;

  final List<Map<String, dynamic>> _visualizationScenes = [
    {
      'title': 'Quiet Beach',
      'emoji': '🌊',
      'description':
      'Imagine gentle waves moving slowly along the shore.',
      'color': Color(0xFFE8F4F6),
    },
    {
      'title': 'Peaceful Forest',
      'emoji': '🌲',
      'description':
      'Imagine yourself surrounded by quiet trees and fresh air.',
      'color': Color(0xFFEAF5EE),
    },
    {
      'title': 'Gentle Rain',
      'emoji': '🌧️',
      'description':
      'Imagine listening to soft rain from somewhere warm and comfortable.',
      'color': Color(0xFFEAF0F7),
    },
    {
      'title': 'Night Sky',
      'emoji': '🌌',
      'description':
      'Imagine looking up at a quiet sky filled with stars.',
      'color': Color(0xFFEDEAF6),
    },
  ];

  // Release the Day
  final TextEditingController _releaseController =
  TextEditingController();

  String? _releaseError;

  // Bedtime Intention
  String? _selectedIntention;
  String? _intentionError;

  final List<Map<String, String>> _intentions = [
    {
      'title': 'Let go of today',
      'emoji': '🌙',
      'description':
      'I can leave today behind and rest now.',
    },
    {
      'title': 'Be gentle with myself',
      'emoji': '💚',
      'description':
      'I do not need to be perfect tonight.',
    },
    {
      'title': 'Tomorrow can wait',
      'emoji': '🌌',
      'description':
      'I can give myself permission to pause.',
    },
    {
      'title': 'Focus on rest',
      'emoji': '😴',
      'description':
      'My only job right now is to recharge.',
    },
  ];

  @override
  void dispose() {
    _visualizationTimer?.cancel();
    _releaseController.dispose();
    super.dispose();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _nextStep() {
    if (!_validateCurrentStep()) {
      return;
    }

    // Bedtime Intention is the final interactive step.
    if (_step == 4) {
      _finishExercise();
      return;
    }

    setState(() {
      _step++;
    });
  }

  void _previousStep() {
    if (_step <= 0) {
      Navigator.pop(context);
      return;
    }

    if (_step == 2) {
      _stopVisualization();
    }

    setState(() {
      _step--;
    });
  }

  bool _validateCurrentStep() {
    if (_step == 1) {
      if (_selectedFeeling == null) {
        setState(() {
          _feelingError = 'Please choose how you are feeling.';
        });
        return false;
      }

      setState(() {
        _feelingError = null;
      });
    }

    if (_step == 2) {
      if (_selectedScene == null) {
        setState(() {
          _visualizationError =
          'Choose a calming place to begin.';
        });
        return false;
      }

      if (_visualizationRemainingSeconds > 0) {
        setState(() {
          _visualizationError =
          'Spend a little time in the visualization before continuing.';
        });
        return false;
      }

      setState(() {
        _visualizationError = null;
      });
    }

    if (_step == 3) {
      if (_releaseController.text.trim().isEmpty) {
        setState(() {
          _releaseError =
          'Write something you would like to leave behind tonight.';
        });
        return false;
      }

      setState(() {
        _releaseError = null;
      });
    }

    if (_step == 4) {
      if (_selectedIntention == null) {
        setState(() {
          _intentionError =
          'Choose an intention for tonight.';
        });
        return false;
      }

      setState(() {
        _intentionError = null;
      });
    }

    return true;
  }

  void _finishExercise() {
    _stopVisualization();

    FocusScope.of(context).unfocus();

    setState(() {
      _isCompleted = true;
    });
  }

  // ============================================================
  // VISUALIZATION
  // ============================================================

  void _startVisualization() {
    if (_selectedScene == null) {
      setState(() {
        _visualizationError =
        'Choose a calming place first.';
      });
      return;
    }

    _visualizationTimer?.cancel();

    setState(() {
      _visualizationRunning = true;
      _visualizationPaused = false;
      _visualizationError = null;
    });

    _visualizationTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_visualizationPaused) {
          return;
        }

        if (_visualizationRemainingSeconds > 0) {
          setState(() {
            _visualizationRemainingSeconds--;
          });
        }

        if (_visualizationRemainingSeconds <= 0) {
          timer.cancel();

          setState(() {
            _visualizationRunning = false;
            _visualizationPaused = false;
          });
        }
      },
    );
  }

  void _pauseVisualization() {
    setState(() {
      _visualizationPaused = true;
    });
  }

  void _resumeVisualization() {
    setState(() {
      _visualizationPaused = false;
    });
  }

  void _stopVisualization() {
    _visualizationTimer?.cancel();

    _visualizationTimer = null;

    if (mounted) {
      setState(() {
        _visualizationRunning = false;
        _visualizationPaused = false;
      });
    }
  }

  void _chooseScene(String scene) {
    _visualizationTimer?.cancel();

    setState(() {
      _selectedScene = scene;
      _visualizationRunning = false;
      _visualizationPaused = false;
      _visualizationRemainingSeconds = 60;
      _visualizationError = null;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;

    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }

  String _getVisualizationPrompt() {
    if (_visualizationRemainingSeconds > 45) {
      return 'Take a slow moment and settle into the scene.';
    }

    if (_visualizationRemainingSeconds > 30) {
      return 'Notice the details around you. There is nowhere else you need to be.';
    }

    if (_visualizationRemainingSeconds > 15) {
      return 'Let your thoughts pass without needing to solve them.';
    }

    if (_visualizationRemainingSeconds > 0) {
      return 'Stay here for a few more moments and allow yourself to rest.';
    }

    return 'Beautiful. Take this calm feeling with you.';
  }

  // ============================================================
  // START AGAIN
  // ============================================================

  void _startAgain() {
    _visualizationTimer?.cancel();

    _releaseController.clear();

    setState(() {
      _step = 0;
      _isCompleted = false;

      _selectedFeeling = null;
      _feelingError = null;

      _selectedScene = null;
      _visualizationRunning = false;
      _visualizationPaused = false;
      _visualizationRemainingSeconds = 60;
      _visualizationError = null;

      _releaseError = null;

      _selectedIntention = null;
      _intentionError = null;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

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
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  10,
                  24,
                  30,
                ),
                child: _buildCurrentStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _previousStep,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                ),
                color: AppColors.navy,
              ),
              const Expanded(
                child: Text(
                  'Sleep Wind-Down',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (_step + 1) / 5,
              minHeight: 5,
              backgroundColor: AppColors.lightMint,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENT STEP
  // ============================================================

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildWelcome();

      case 1:
        return _buildFeelingStep();

      case 2:
        return _buildVisualizationStep();

      case 3:
        return _buildReleaseStep();

      case 4:
        return _buildIntentionStep();

      default:
        return _buildWelcome();
    }
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcome() {
    return Column(
      children: [
        const SizedBox(height: 25),

        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderMint,
              width: 1,
            ),
          ),
          child: const Center(
            child: Text(
              '🌙',
              style: TextStyle(
                fontSize: 52,
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          'Sleep Wind-Down',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 29,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'A gentle space to slow down, clear your mind, and prepare for rest.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            height: 1.55,
          ),
        ),

        const SizedBox(height: 28),

        _buildInfoCard(
          icon: Icons.nightlight_round,
          title: 'A few quiet minutes',
          description:
          'There is nothing you need to achieve here. Just give yourself permission to slow down.',
        ),

        const SizedBox(height: 14),

        _buildInfoCard(
          icon: Icons.self_improvement_rounded,
          title: 'Go at your own pace',
          description:
          'Choose what feels comfortable and let the day gradually come to an end.',
        ),

        const SizedBox(height: 35),

        _buildPrimaryButton(
          text: 'Begin Wind-Down',
          icon: Icons.arrow_forward_rounded,
          onPressed: _nextStep,
        ),

        const SizedBox(height: 16),

        const Text(
          'You deserve a moment of rest.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.mint,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FEELING
  // ============================================================

  Widget _buildFeelingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        _buildStepHeader(
          emoji: '😌',
          title: 'How are you feeling?',
          subtitle:
          'There is no right answer. Just choose what feels closest right now.',
        ),

        const SizedBox(height: 28),

        const Text(
          'Choose one',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _feelings.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.65,
          ),
          itemBuilder: (context, index) {
            final feeling = _feelings[index];

            final title = feeling['title']!;
            final emoji = feeling['emoji']!;

            final isSelected = _selectedFeeling == title;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFeeling = title;
                  _feelingError = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.lightMint
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.mint
                        : AppColors.borderMint,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(
                        fontSize: 27,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.mint,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        if (_feelingError != null) ...[
          const SizedBox(height: 12),
          _buildErrorMessage(_feelingError!),
        ],

        const SizedBox(height: 35),

        _buildPrimaryButton(
          text: 'Continue',
          icon: Icons.arrow_forward_rounded,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // ============================================================
  // CALM VISUALIZATION
  // ============================================================

  Widget _buildVisualizationStep() {
    Map<String, dynamic>? selectedScene;

    if (_selectedScene != null) {
      for (final scene in _visualizationScenes) {
        if (scene['title'] == _selectedScene) {
          selectedScene = scene;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        _buildStepHeader(
          emoji: '🌌',
          title: 'Calm Visualization',
          subtitle:
          'Choose a peaceful place and spend a quiet minute imagining yourself there.',
        ),

        const SizedBox(height: 24),

        const Text(
          'Choose your peaceful place',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 14),

        ..._visualizationScenes.map(
              (scene) {
            final title = scene['title'] as String;
            final emoji = scene['emoji'] as String;
            final description =
            scene['description'] as String;
            final color = scene['color'] as Color;

            final isSelected = _selectedScene == title;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _chooseScene(title),
                child: AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color
                        : Colors.white,
                    borderRadius:
                    BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.mint
                          : AppColors.borderMint,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.75,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(
                              fontSize: 29,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              description,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.mint,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        if (_selectedScene != null &&
            selectedScene != null) ...[
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.borderMint,
              ),
            ),
            child: Column(
              children: [
                Text(
                  selectedScene['emoji'] as String,
                  style: const TextStyle(
                    fontSize: 44,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  selectedScene['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _getVisualizationPrompt(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.borderMint,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _formatTime(
                        _visualizationRemainingSeconds,
                      ),
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (!_visualizationRunning &&
                    _visualizationRemainingSeconds > 0)
                  _buildPrimaryButton(
                    text: 'Begin Visualization',
                    icon: Icons.play_arrow_rounded,
                    onPressed: _startVisualization,
                  ),

                if (_visualizationRunning)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                          _visualizationPaused
                              ? _resumeVisualization
                              : _pauseVisualization,
                          icon: Icon(
                            _visualizationPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                          ),
                          label: Text(
                            _visualizationPaused
                                ? 'Resume'
                                : 'Pause',
                          ),
                          style:
                          OutlinedButton.styleFrom(
                            foregroundColor:
                            AppColors.navy,
                            side: const BorderSide(
                              color: AppColors.borderMint,
                            ),
                            padding:
                            const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                if (!_visualizationRunning &&
                    _visualizationRemainingSeconds ==
                        0) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.mint,
                          size: 21,
                        ),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Visualization complete. Take this calm feeling with you.',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 13,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        if (_visualizationError != null) ...[
          const SizedBox(height: 12),
          _buildErrorMessage(
            _visualizationError!,
          ),
        ],

        const SizedBox(height: 30),

        _buildPrimaryButton(
          text: 'Continue',
          icon: Icons.arrow_forward_rounded,
          onPressed: _nextStep,
        ),

        const SizedBox(height: 8),

        const Text(
          'You can choose another place anytime before continuing.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RELEASE THE DAY
  // ============================================================

  Widget _buildReleaseStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        _buildStepHeader(
          emoji: '📝',
          title: 'Release the Day',
          subtitle:
          'You do not need to carry everything from today into tomorrow.',
        ),

        const SizedBox(height: 28),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(20),
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
                size: 23,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Write down one thing you would like to leave behind for tonight.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'What would you like to let go of?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: _releaseController,
          minLines: 6,
          maxLines: 8,
          textInputAction: TextInputAction.newline,
          onChanged: (_) {
            if (_releaseError != null) {
              setState(() {
                _releaseError = null;
              });
            }
          },
          decoration: InputDecoration(
            hintText:
            'For example: I am letting go of worrying about tomorrow...',
            hintStyle: const TextStyle(
              color: Colors.black38,
              fontSize: 14,
              height: 1.45,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(17),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.borderMint,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.borderMint,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.mint,
                width: 1.5,
              ),
            ),
          ),
        ),

        if (_releaseError != null) ...[
          const SizedBox(height: 10),
          _buildErrorMessage(_releaseError!),
        ],

        const SizedBox(height: 30),

        _buildPrimaryButton(
          text: 'Continue',
          icon: Icons.arrow_forward_rounded,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // ============================================================
  // BEDTIME INTENTION
  // ============================================================

  Widget _buildIntentionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        _buildStepHeader(
          emoji: '🌙',
          title: 'Bedtime Intention',
          subtitle:
          'Choose one gentle thought you would like to take into the night.',
        ),

        const SizedBox(height: 28),

        const Text(
          'Tonight, I want to...',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 14),

        ..._intentions.map(
              (intention) {
            final title = intention['title']!;
            final emoji = intention['emoji']!;
            final description =
            intention['description']!;

            final isSelected =
                _selectedIntention == title;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIntention = title;
                    _intentionError = null;
                  });
                },
                child: AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.lightMint
                        : Colors.white,
                    borderRadius:
                    BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.mint
                          : AppColors.borderMint,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(
                              fontSize: 25,
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
                              title,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 15,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              description,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(
                            left: 8,
                          ),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.mint,
                            size: 21,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        if (_intentionError != null) ...[
          const SizedBox(height: 8),
          _buildErrorMessage(_intentionError!),
        ],

        const SizedBox(height: 25),

        _buildPrimaryButton(
          text: 'Finish Wind-Down',
          icon: Icons.check_rounded,
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // ============================================================
  // COMPLETION PAGE
  // ============================================================

  Widget _buildCompletionPage() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            35,
            24,
            35,
          ),
          child: Column(
            children: [
              Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderMint,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.mint,
                    size: 58,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Wind-Down Complete',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'You have given yourself some quiet space to slow down and prepare for rest.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  height: 1.55,
                ),
              ),

              const SizedBox(height: 28),

              _buildSummaryCard(
                icon: '😌',
                title: 'How you felt',
                value:
                _selectedFeeling ?? 'Not selected',
              ),

              const SizedBox(height: 12),

              _buildSummaryCard(
                icon: '🌌',
                title: 'Calm visualization',
                value:
                _selectedScene ?? 'Not selected',
              ),

              const SizedBox(height: 12),

              _buildSummaryCard(
                icon: '📝',
                title: 'Released for tonight',
                value: _releaseController.text.trim(),
              ),

              const SizedBox(height: 12),

              _buildSummaryCard(
                icon: '🌙',
                title: 'Bedtime intention',
                value:
                _selectedIntention ?? 'Not selected',
              ),

              const SizedBox(height: 22),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.nightlight_round,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'You do not have to solve everything tonight.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Let today be enough. Tomorrow can wait.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _buildPrimaryButton(
                text: 'Done',
                icon: Icons.check_rounded,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _startAgain,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(
                      color: AppColors.borderMint,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start Again',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'This exercise is for relaxation and reflection, not medical treatment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REUSABLE UI
  // ============================================================

  Widget _buildStepHeader({
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightMint,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: AppColors.mint,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
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

  Widget _buildPrimaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Colors.redAccent,
          size: 18,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(
              fontSize: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}