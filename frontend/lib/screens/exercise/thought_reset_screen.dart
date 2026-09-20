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

  void _clearPerspectiveError() {
    if (_perspectiveError != null) {
      setState(() {
        _perspectiveError = null;
      });
    }
  }

  void _clearNextStepError() {
    if (_nextStepError != null) {
      setState(() {
        _nextStepError = null;
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

    if (!valid) {
      _showValidationAlert();
    }

    return valid;
  }

  void _showValidationAlert() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Please complete the highlighted section first.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 40,
                    color: AppColors.mint,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thought Reset Complete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You gave yourself a moment to pause, reflect, and choose your next step.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '🌱',
                        style: TextStyle(fontSize: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedNextStep ?? 'Take one small step',
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
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
              ],
            ),
          ),
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
            _buildProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousStep,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppColors.navy,
            ),
          ),
          const Expanded(
            child: Text(
              'Thought Reset',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
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
                  _feelingError = null;
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
          text: 'You do not need to explain everything. Just start with what feels important.',
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
                final current = _thoughtController.text.trim();

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
    if (error == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        top: 8,
        bottom: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
}