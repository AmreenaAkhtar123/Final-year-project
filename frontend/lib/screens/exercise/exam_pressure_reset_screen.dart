import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ExamPressureResetScreen extends StatefulWidget {
  const ExamPressureResetScreen({super.key});

  @override
  State<ExamPressureResetScreen> createState() =>
      _ExamPressureResetScreenState();
}

class _ExamPressureResetScreenState
    extends State<ExamPressureResetScreen> {
  int _step = 0;

  String? _selectedPressure;
  String? _selectedProblem;
  String? _selectedAction;

  final TextEditingController _studyDifficultyController =
  TextEditingController();

  String? _pressureError;
  String? _problemError;
  String? _studyDifficultyError;
  String? _actionError;

  bool _isCompleted = false;

  final List<Map<String, dynamic>> _pressureOptions = [
    {
      'title': 'I feel anxious',
      'icon': '😰',
    },
    {
      'title': 'There is too much to study',
      'icon': '📚',
    },
    {
      'title': 'I am running out of time',
      'icon': '⏰',
    },
    {
      'title': 'I am afraid of failing',
      'icon': '😟',
    },
    {
      'title': 'There is pressure from others',
      'icon': '👥',
    },
    {
      'title': 'Everything feels like too much',
      'icon': '😵',
    },
  ];

  final List<Map<String, dynamic>> _problemOptions = [
    {
      'title': 'I need to start studying',
      'icon': '🚀',
    },
    {
      'title': 'I need to organize my work',
      'icon': '🗂️',
    },
    {
      'title': 'I need to remember things better',
      'icon': '🧠',
    },
    {
      'title': 'I need to manage my time',
      'icon': '⏱️',
    },
    {
      'title': 'I need to calm down first',
      'icon': '🌿',
    },
  ];

  final List<Map<String, dynamic>> _actionOptions = [
    {
      'title': 'Study for 10 minutes',
      'icon': '📖',
    },
    {
      'title': 'Choose one topic',
      'icon': '🎯',
    },
    {
      'title': 'Take a short reset',
      'icon': '🌿',
    },
    {
      'title': 'Take a short break',
      'icon': '☕',
    },
    {
      'title': 'Ask someone for help',
      'icon': '💬',
    },
  ];

  @override
  void dispose() {
    _studyDifficultyController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    bool valid = true;

    if (_step == 0) {
      if (_selectedPressure == null) {
        setState(() {
          _pressureError =
          'Please choose what is putting pressure on you.';
        });
        valid = false;
      } else {
        setState(() {
          _pressureError = null;
        });
      }
    }

    if (_step == 1) {
      if (_selectedProblem == null) {
        setState(() {
          _problemError =
          'Please choose what would help you most.';
        });
        valid = false;
      } else {
        setState(() {
          _problemError = null;
        });
      }
    }

    if (_step == 2) {
      if (_studyDifficultyController.text.trim().isEmpty) {
        setState(() {
          _studyDifficultyError =
          'Please write what is making studying difficult.';
        });
        valid = false;
      } else {
        setState(() {
          _studyDifficultyError = null;
        });
      }
    }

    if (_step == 3) {
      if (_selectedAction == null) {
        setState(() {
          _actionError =
          'Please choose one small next step.';
        });
        valid = false;
      } else {
        setState(() {
          _actionError = null;
        });
      }
    }

    return valid;
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();

    if (!_validateCurrentStep()) {
      return;
    }

    if (_step < 3) {
      setState(() {
        _step++;
      });
    } else {
      _finishExercise();
    }
  }

  void _previousStep() {
    FocusScope.of(context).unfocus();

    if (_step > 0) {
      setState(() {
        _step--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _finishExercise() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isCompleted = true;
    });
  }

  void _startAgain() {
    setState(() {
      _isCompleted = false;
      _step = 0;

      _selectedPressure = null;
      _selectedProblem = null;
      _selectedAction = null;

      _studyDifficultyController.clear();

      _pressureError = null;
      _problemError = null;
      _studyDifficultyError = null;
      _actionError = null;
    });
  }

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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  30,
                ),
                child: Column(
                  children: [
                    _buildProgress(),

                    const SizedBox(height: 26),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildCurrentStep(),
                    ),

                    const SizedBox(height: 28),

                    _buildBottomButton(),
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
                onTap: _previousStep,
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
                  'Exam Pressure Reset',
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

  Widget _buildProgress() {
    return Column(
      children: [
        Row(
          children: List.generate(
            4,
                (index) {
              final bool completed = index < _step;
              final bool active = index == _step;

              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(
                    right: index == 3 ? 0 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: completed || active
                        ? AppColors.mint
                        : AppColors.borderMint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Step ${_step + 1} of 4',
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildPressureStep();

      case 1:
        return _buildProblemStep();

      case 2:
        return _buildDifficultyStep();

      case 3:
        return _buildActionStep();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPressureStep() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIcon('📚'),

        const SizedBox(height: 18),

        const Text(
          'What is putting pressure on you?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Choose what feels closest right now. There is no wrong answer.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 22),

        ..._pressureOptions.map(
              (option) => Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _buildChoiceCard(
              title: option['title'],
              icon: option['icon'],
              selected: _selectedPressure == option['title'],
              onTap: () {
                setState(() {
                  _selectedPressure = option['title'];
                  _pressureError = null;
                });
              },
            ),
          ),
        ),

        _buildError(_pressureError),
      ],
    );
  }

  Widget _buildProblemStep() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIcon('🧭'),

        const SizedBox(height: 18),

        const Text(
          'What would help you most?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'You do not need to fix everything. Just identify what you need first.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 22),

        ..._problemOptions.map(
              (option) => Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _buildChoiceCard(
              title: option['title'],
              icon: option['icon'],
              selected: _selectedProblem == option['title'],
              onTap: () {
                setState(() {
                  _selectedProblem = option['title'];
                  _problemError = null;
                });
              },
            ),
          ),
        ),

        _buildError(_problemError),
      ],
    );
  }

  Widget _buildDifficultyStep() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIcon('💭'),

        const SizedBox(height: 18),

        const Text(
          'What is making studying difficult?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Write a few words about what is getting in the way right now.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 22),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _studyDifficultyError != null
                  ? Colors.red
                  : AppColors.borderMint,
              width: _studyDifficultyError != null ? 1.4 : 1,
            ),
          ),
          child: TextField(
            controller: _studyDifficultyController,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            onChanged: (_) {
              if (_studyDifficultyError != null) {
                setState(() {
                  _studyDifficultyError = null;
                });
              }
            },
            decoration: const InputDecoration(
              hintText:
              'For example: I keep worrying about failing...',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(18),
            ),
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),

        _buildError(_studyDifficultyError),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.lightMint,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.borderMint,
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: AppColors.mint,
                size: 19,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This reflection stays on your device for now and is only used to guide this exercise.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionStep() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIcon('🌱'),

        const SizedBox(height: 18),

        const Text(
          'What is one small thing you can do next?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Pick something small enough that you can actually start.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 22),

        ..._actionOptions.map(
              (option) => Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _buildChoiceCard(
              title: option['title'],
              icon: option['icon'],
              selected: _selectedAction == option['title'],
              onTap: () {
                setState(() {
                  _selectedAction = option['title'];
                  _actionError = null;
                });
              },
            ),
          ),
        ),

        _buildError(_actionError),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💚',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You do not have to finish everything today. One small step is still progress.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.5,
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

  Widget _buildStepIcon(String emoji) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(
            fontSize: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightMint
              : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? AppColors.mint
                : AppColors.borderMint,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white
                    : AppColors.lightMint,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),

            const SizedBox(width: 8),

            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
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
                size: 15,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String? error) {
    if (error == null || error.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 10,
        bottom: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFCACA),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _step == 3 ? 'Complete Reset' : 'Continue',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _step == 3
                  ? Icons.check_rounded
                  : Icons.arrow_forward_rounded,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionPage() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              // Header
              Row(
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
                        'Exam Pressure Reset',
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

              const SizedBox(height: 30),

              // Success icon
              Center(
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.borderMint,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.mint,
                    size: 52,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Center(
                child: Text(
                  'Reset Complete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'You took a moment to understand the pressure and choose your next step.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Your Reset Summary',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 13),

              _buildSummaryItem(
                icon: '📚',
                title: 'What feels hardest',
                value: _selectedPressure ?? '',
              ),

              const SizedBox(height: 10),

              _buildSummaryItem(
                icon: '🧭',
                title: 'What you need',
                value: _selectedProblem ?? '',
              ),

              const SizedBox(height: 10),

              _buildSummaryItem(
                icon: '💭',
                title: 'What is making studying difficult',
                value: _studyDifficultyController.text.trim(),
              ),

              const SizedBox(height: 10),

              _buildSummaryItem(
                icon: '🌱',
                title: 'Your next step',
                value: _selectedAction ?? '',
                highlighted: true,
              ),

              const SizedBox(height: 24),

              // Encouragement
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '💚',
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'One step is enough for now.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'You do not have to solve everything at once. Focus on the small action you chose and take it one step at a time.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Done
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Start again
              Center(
                child: TextButton(
                  onPressed: _startAgain,
                  child: const Text(
                    'Start Again',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String icon,
    required String title,
    required String value,
    bool highlighted = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.lightMint
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted
              ? AppColors.mint
              : AppColors.borderMint,
          width: highlighted ? 1.4 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(
              fontSize: 23,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
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