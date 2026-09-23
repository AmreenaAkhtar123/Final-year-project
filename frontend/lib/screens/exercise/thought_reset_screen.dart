import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class ThoughtResetScreen extends StatefulWidget {
  const ThoughtResetScreen({super.key});

  @override
  State<ThoughtResetScreen> createState() => _ThoughtResetScreenState();
}

class _ThoughtResetScreenState extends State<ThoughtResetScreen> {
  int _step = 0;

  String? _selectedFeeling;
  String? _selectedPerspective;
  String? _selectedNextStep;

  final TextEditingController _botheringController =
  TextEditingController();

  final TextEditingController _thoughtController =
  TextEditingController();

  String? _feelingError;
  String? _botheringError;
  String? _thoughtError;
  String? _perspectiveError;
  String? _nextStepError;

  bool _isCompleted = false;

  final List<Map<String, dynamic>> _feelings = [
    {
      'emoji': '😰',
      'title': 'Worried',
      'color': const Color(0xFFFFF4E5),
    },
    {
      'emoji': '😔',
      'title': 'Feeling low',
      'color': const Color(0xFFF0EEFF),
    },
    {
      'emoji': '😤',
      'title': 'Frustrated',
      'color': const Color(0xFFFFEEEE),
    },
    {
      'emoji': '😵',
      'title': 'Overwhelmed',
      'color': const Color(0xFFEFF7F3),
    },
    {
      'emoji': '🧠',
      'title': 'Can’t stop thinking',
      'color': const Color(0xFFEAF3FF),
    },
    {
      'emoji': '🤷',
      'title': 'Not sure',
      'color': const Color(0xFFF5F5F5),
    },
  ];

  final List<Map<String, dynamic>> _perspectives = [
    {
      'emoji': '🌱',
      'title': 'Maybe this is temporary',
      'subtitle': 'This moment does not define everything.',
    },
    {
      'emoji': '🧩',
      'title': 'Maybe I don’t have the full picture',
      'subtitle': 'There may be things I cannot see yet.',
    },
    {
      'emoji': '🪜',
      'title': 'Maybe I only need the next step',
      'subtitle': 'I do not have to solve everything now.',
    },
    {
      'emoji': '💚',
      'title': 'Maybe I need to be kinder to myself',
      'subtitle': 'I can respond to myself with patience.',
    },
    {
      'emoji': '🤷',
      'title': 'Help me choose',
      'subtitle': 'I am not sure what perspective I need.',
    },
  ];

  final List<Map<String, dynamic>> _nextSteps = [
    {
      'emoji': '🫁',
      'title': 'Calm down',
      'subtitle': 'Take a short breathing or grounding pause.',
    },
    {
      'emoji': '📚',
      'title': 'Do one small task',
      'subtitle': 'Focus only on one manageable thing.',
    },
    {
      'emoji': '🚶',
      'title': 'Take a break',
      'subtitle': 'Step away and give your mind some space.',
    },
    {
      'emoji': '💬',
      'title': 'Talk to someone',
      'subtitle': 'Reach out to someone you trust.',
    },
    {
      'emoji': '📝',
      'title': 'Keep reflecting',
      'subtitle': 'Spend a little more time understanding this feeling.',
    },
  ];

  @override
  void dispose() {
    _botheringController.dispose();
    _thoughtController.dispose();
    super.dispose();
  }

  void _clearFeelingError() {
    if (_feelingError != null) {
      setState(() {
        _feelingError = null;
      });
    }
  }

  void _clearBotheringError() {
    if (_botheringError != null) {
      setState(() {
        _botheringError = null;
      });
    }
  }

  void _clearThoughtError() {
    if (_thoughtError != null) {
      setState(() {
        _thoughtError = null;
      });
    }
  }

  bool _validateCurrentStep() {
    bool valid = true;

    setState(() {
      if (_step == 0) {
        _feelingError = null;

        if (_selectedFeeling == null) {
          _feelingError =
          'Please choose how you are feeling right now.';
          valid = false;
        }
      }

      if (_step == 1) {
        _botheringError = null;

        if (_botheringController.text.trim().isEmpty) {
          _botheringError =
          'Please tell us what is bothering you most.';
          valid = false;
        }
      }

      if (_step == 2) {
        _thoughtError = null;

        if (_thoughtController.text.trim().isEmpty) {
          _thoughtError =
          'Please write what your mind keeps saying.';
          valid = false;
        }
      }

      if (_step == 3) {
        _perspectiveError = null;

        if (_selectedPerspective == null) {
          _perspectiveError =
          'Please choose one option to continue.';
          valid = false;
        }
      }

      if (_step == 4) {
        _nextStepError = null;

        if (_selectedNextStep == null) {
          _nextStepError =
          'Please choose what would help you right now.';
          valid = false;
        }
      }
    });

    // No alert or SnackBar.
    // The inline error is enough.

    return valid;
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();

    if (!_validateCurrentStep()) {
      return;
    }

    if (_step < 4) {
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

      _selectedFeeling = null;
      _selectedPerspective = null;
      _selectedNextStep = null;

      _botheringController.clear();
      _thoughtController.clear();

      _feelingError = null;
      _botheringError = null;
      _thoughtError = null;
      _perspectiveError = null;
      _nextStepError = null;
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
            _buildProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  10,
                  22,
                  28,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildCurrentStep(),
                ),
              ),
            ),
            _buildBottomButton(),
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
                  'Thought Reset',
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Row(
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_step + 1} of 5',
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildFeelingStep();
      case 1:
        return _buildBotheringStep();
      case 2:
        return _buildThoughtStep();
      case 3:
        return _buildPerspectiveStep();
      case 4:
        return _buildNextStepSelection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFeelingStep() {
    return Column(
      key: const ValueKey('feeling'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        _buildStepIcon('💭'),
        const SizedBox(height: 20),
        const Text(
          'What’s going on right now?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'There is no right or wrong answer. Just choose what feels closest.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
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
            final item = _feelings[index];
            final selected =
                _selectedFeeling == item['title'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFeeling = item['title'];
                  _clearFeelingError();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: item['color'],
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? AppColors.mint
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      item['emoji'],
                      style: const TextStyle(fontSize: 27),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        item['title'],
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (selected)
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
        _buildError(_feelingError),
      ],
    );
  }

  Widget _buildBotheringStep() {
    return Column(
      key: const ValueKey('bothering'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        _buildStepIcon('🧩'),
        const SizedBox(height: 20),
        const Text(
          'What’s bothering you most?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'You can keep it simple. A few words are enough.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        _buildTextField(
          controller: _botheringController,
          hint: 'For example: exams, friends, family...',
          maxLines: 5,
          onChanged: (_) => _clearBotheringError(),
        ),
        _buildError(_botheringError),
        const SizedBox(height: 14),
        _buildTipCard(
          icon: Icons.lightbulb_outline_rounded,
          text:
          'You do not need to explain everything. Just start with what feels important.',
        ),
      ],
    );
  }

  Widget _buildThoughtStep() {
    return Column(
      key: const ValueKey('thought'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        _buildStepIcon('🧠'),
        const SizedBox(height: 20),
        const Text(
          'What does your mind keep saying?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Write the thought that keeps coming back. It does not have to be perfect.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        _buildTextField(
          controller: _thoughtController,
          hint: 'Write the thought here...',
          maxLines: 5,
          onChanged: (_) => _clearThoughtError(),
        ),
        _buildError(_thoughtError),
        const SizedBox(height: 20),
        const Text(
          'Or start with one of these:',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'I’m worried that...',
            'I keep thinking...',
            'What if...',
            'I feel like...',
          ].map((text) {
            return GestureDetector(
              onTap: () {
                final current =
                _thoughtController.text.trim();

                setState(() {
                  if (current.isEmpty) {
                    _thoughtController.text = text;
                  } else {
                    _thoughtController.text =
                    '$current $text';
                  }
                  _thoughtError = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPerspectiveStep() {
    return Column(
      key: const ValueKey('perspective'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        _buildStepIcon('🌱'),
        const SizedBox(height: 20),
        const Text(
          'Let’s look at it differently.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'You do not have to believe a new thought completely. Just see if one feels possible.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        ..._perspectives.map(
              (item) => _buildChoiceCard(
            emoji: item['emoji'],
            title: item['title'],
            subtitle: item['subtitle'],
            selected:
            _selectedPerspective == item['title'],
            onTap: () {
              setState(() {
                _selectedPerspective = item['title'];
                _perspectiveError = null;
              });
            },
          ),
        ),
        _buildError(_perspectiveError),
      ],
    );
  }

  Widget _buildNextStepSelection() {
    return Column(
      key: const ValueKey('next'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        _buildStepIcon('🪜'),
        const SizedBox(height: 20),
        const Text(
          'What would help right now?',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose one small action. You do not need to fix everything today.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        ..._nextSteps.map(
              (item) => _buildChoiceCard(
            emoji: item['emoji'],
            title: item['title'],
            subtitle: item['subtitle'],
            selected:
            _selectedNextStep == item['title'],
            onTap: () {
              setState(() {
                _selectedNextStep = item['title'];
                _nextStepError = null;
              });
            },
          ),
        ),
        _buildError(_nextStepError),
        const SizedBox(height: 20),
        _buildClosingMessage(),
      ],
    );
  }

  Widget _buildStepIcon(String emoji) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 31),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildChoiceCard({
    required String emoji,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white
                    : AppColors.lightMint,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 23),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? AppColors.mint
                  : Colors.grey.shade400,
              size: 23,
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
        bottom: 4,
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

  Widget _buildTipCard({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.mint,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Text(
            '💚',
            style: TextStyle(fontSize: 26),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'You do not have to solve everything right now.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final isLast = _step == 4;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLast ? 'Complete Reset' : 'Continue',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isLast
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionPage() {
    final selectedFeelingData = _feelings.firstWhere(
          (item) => item['title'] == _selectedFeeling,
      orElse: () => {
        'emoji': '💭',
        'title': _selectedFeeling ?? 'Not selected',
      },
    );

    final selectedPerspectiveData = _perspectives.firstWhere(
          (item) => item['title'] == _selectedPerspective,
      orElse: () => {
        'emoji': '🌱',
        'title': _selectedPerspective ?? 'Not selected',
        'subtitle': '',
      },
    );

    final selectedNextStepData = _nextSteps.firstWhere(
          (item) => item['title'] == _selectedNextStep,
      orElse: () => {
        'emoji': '🌱',
        'title': _selectedNextStep ?? 'Not selected',
        'subtitle': '',
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        'Thought Reset',
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

              const SizedBox(height: 28),

              // Success section
              Center(
                child: Container(
                  width: 94,
                  height: 94,
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
                    size: 54,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Center(
                child: Text(
                  'Thought Reset Complete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'You gave yourself a moment to pause, understand what is happening, and choose a helpful next step.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Your Reflection',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 13),

              // Feeling result
              _buildResultCard(
                emoji: selectedFeelingData['emoji'],
                label: 'How you were feeling',
                value: selectedFeelingData['title'],
                highlighted: true,
              ),

              const SizedBox(height: 10),

              // Bothering result
              _buildResultCard(
                emoji: '🧩',
                label: 'What was bothering you',
                value: _botheringController.text.trim(),
              ),

              const SizedBox(height: 10),

              // Thought result
              _buildResultCard(
                emoji: '🧠',
                label: 'What your mind kept saying',
                value: _thoughtController.text.trim(),
              ),

              const SizedBox(height: 10),

              // Perspective result
              _buildResultCard(
                emoji: selectedPerspectiveData['emoji'],
                label: 'The perspective you chose',
                value: selectedPerspectiveData['title'],
              ),

              const SizedBox(height: 10),

              // Next step result
              _buildResultCard(
                emoji: selectedNextStepData['emoji'],
                label: 'Your next step',
                value: selectedNextStepData['title'],
                subtitle: selectedNextStepData['subtitle'],
                highlighted: true,
              ),

              const SizedBox(height: 24),

              // Closing message
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
                            fontSize: 26,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You do not have to solve everything right now.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Take your chosen next step at your own pace. Small progress still counts.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Done button
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
                      borderRadius: BorderRadius.circular(17),
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

  Widget _buildResultCard({
    required String emoji,
    required String label,
    required String value,
    String? subtitle,
    bool highlighted = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.lightMint
            : Colors.white,
        borderRadius: BorderRadius.circular(17),
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
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: highlighted
                  ? Colors.white
                  : AppColors.lightMint,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(
                  fontSize: 22,
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
                  label,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),

                if (subtitle != null &&
                    subtitle.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}