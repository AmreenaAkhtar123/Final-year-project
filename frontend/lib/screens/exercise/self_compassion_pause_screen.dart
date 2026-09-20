import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class SelfCompassionPauseScreen extends StatefulWidget {
  const SelfCompassionPauseScreen({super.key});

  @override
  State<SelfCompassionPauseScreen> createState() =>
      _SelfCompassionPauseScreenState();
}

class _SelfCompassionPauseScreenState
    extends State<SelfCompassionPauseScreen> {
  // ------------------------------------------------------------
  // STEP CONTROL
  // ------------------------------------------------------------

  int _step = 0;
  bool _isCompleted = false;

  // ------------------------------------------------------------
  // STEP 1 — WHAT ARE YOU BEING HARD ON YOURSELF ABOUT?
  // ------------------------------------------------------------

  final TextEditingController _situationController =
  TextEditingController();

  String? _situationError;

  // ------------------------------------------------------------
  // STEP 2 — FRIEND PERSPECTIVE
  // ------------------------------------------------------------

  String? _selectedFriendResponse;
  String? _friendResponseError;

  final List<Map<String, dynamic>> _friendResponses = [
    {
      'title': 'I would listen without judging',
      'icon': Icons.hearing_outlined,
    },
    {
      'title': 'I would remind them they are trying',
      'icon': Icons.favorite_outline_rounded,
    },
    {
      'title': 'I would tell them mistakes happen',
      'icon': Icons.refresh_rounded,
    },
    {
      'title': 'I would help them take one step',
      'icon': Icons.directions_walk_outlined,
    },
  ];

  // ------------------------------------------------------------
  // STEP 3 — INNER CRITIC
  // ------------------------------------------------------------

  final TextEditingController _criticController =
  TextEditingController();

  String? _criticError;

  // ------------------------------------------------------------
  // STEP 4 — KINDER RESPONSE
  // ------------------------------------------------------------

  final TextEditingController _kindResponseController =
  TextEditingController();

  String? _kindResponseError;

  // ------------------------------------------------------------
  // STEP 5 — PERMISSION
  // ------------------------------------------------------------

  String? _selectedPermission;
  String? _permissionError;

  final List<Map<String, dynamic>> _permissions = [
    {
      'title': 'I can take my time',
      'subtitle': 'I do not have to rush everything.',
      'icon': Icons.schedule_outlined,
    },
    {
      'title': 'I can make mistakes',
      'subtitle': 'A mistake does not define me.',
      'icon': Icons.auto_fix_high_outlined,
    },
    {
      'title': 'I can ask for help',
      'subtitle': 'I do not have to handle everything alone.',
      'icon': Icons.people_outline,
    },
    {
      'title': 'I can rest',
      'subtitle': 'Rest is allowed, even when things are unfinished.',
      'icon': Icons.bed_outlined,
    },
    {
      'title': 'I can start again',
      'subtitle': 'One difficult moment does not decide the whole day.',
      'icon': Icons.restart_alt_rounded,
    },
  ];

  @override
  void dispose() {
    _situationController.dispose();
    _criticController.dispose();
    _kindResponseController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // NAVIGATION
  // ------------------------------------------------------------

  void _goBack() {
    FocusScope.of(context).unfocus();

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

  // ------------------------------------------------------------
  // VALIDATION
  // ------------------------------------------------------------

  bool _validateCurrentStep() {
    setState(() {
      _situationError = null;
      _friendResponseError = null;
      _criticError = null;
      _kindResponseError = null;
      _permissionError = null;
    });

    switch (_step) {
      case 0:
        final text = _situationController.text.trim();

        if (text.isEmpty) {
          setState(() {
            _situationError =
            'Please write what you are being hard on yourself about.';
          });
          return false;
        }

        if (text.length < 5) {
          setState(() {
            _situationError =
            'Please write a little more so you can reflect on it.';
          });
          return false;
        }

        return true;

      case 1:
        if (_selectedFriendResponse == null) {
          setState(() {
            _friendResponseError =
            'Please choose the response that feels most like you.';
          });
          return false;
        }

        return true;

      case 2:
        final text = _criticController.text.trim();

        if (text.isEmpty) {
          setState(() {
            _criticError =
            'Please write what your inner critic is saying.';
          });
          return false;
        }

        if (text.length < 3) {
          setState(() {
            _criticError =
            'Please write a little more about that thought.';
          });
          return false;
        }

        return true;

      case 3:
        final text = _kindResponseController.text.trim();

        if (text.isEmpty) {
          setState(() {
            _kindResponseError =
            'Please write a kinder response to yourself.';
          });
          return false;
        }

        if (text.length < 5) {
          setState(() {
            _kindResponseError =
            'Please write a little more so your response feels meaningful.';
          });
          return false;
        }

        return true;

      case 4:
        if (_selectedPermission == null) {
          setState(() {
            _permissionError =
            'Please choose one permission you want to give yourself.';
          });
          return false;
        }

        return true;

      default:
        return true;
    }
  }

  // ------------------------------------------------------------
  // FINISH
  // ------------------------------------------------------------

  void _finishExercise() {
    FocusScope.of(context).unfocus();

    if (!_validateCurrentStep()) {
      return;
    }

    setState(() {
      _isCompleted = true;
    });
  }

  // ------------------------------------------------------------
  // START AGAIN
  // ------------------------------------------------------------

  void _startAgain() {
    FocusScope.of(context).unfocus();

    setState(() {
      _step = 0;
      _isCompleted = false;

      _situationController.clear();
      _situationError = null;

      _selectedFriendResponse = null;
      _friendResponseError = null;

      _criticController.clear();
      _criticError = null;

      _kindResponseController.clear();
      _kindResponseError = null;

      _selectedPermission = null;
      _permissionError = null;
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.borderMint,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.navy,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Self-Compassion Pause',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
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
        return _buildSituationStep();

      case 1:
        return _buildFriendPerspectiveStep();

      case 2:
        return _buildInnerCriticStep();

      case 3:
        return _buildKindResponseStep();

      case 4:
        return _buildPermissionStep();

      default:
        return const SizedBox.shrink();
    }
  }

  // ------------------------------------------------------------
  // STEP 1
  // ------------------------------------------------------------

  Widget _buildSituationStep() {
    return SingleChildScrollView(
      key: const ValueKey('situation'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepNumber('01'),
          const SizedBox(height: 14),

          const Text(
            'What are you being hard on yourself about?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Think of one moment, mistake, worry, or situation that is weighing on you.',
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.65),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 26),

          _buildTextArea(
            controller: _situationController,
            hint:
            'For example:\n\n“I didn’t study as much as I planned.”\n\n“I made a mistake in front of people.”\n\n“I feel like I’m falling behind.”',
            error: _situationError,
            onChanged: () {
              if (_situationError != null) {
                setState(() {
                  _situationError = null;
                });
              }
            },
          ),

          const SizedBox(height: 18),

          _buildGentleNote(
            icon: Icons.visibility_outlined,
            text:
            'There is no need to judge the situation here. Just notice it.',
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
  // STEP 2
  // ------------------------------------------------------------

  Widget _buildFriendPerspectiveStep() {
    return SingleChildScrollView(
      key: const ValueKey('friend-perspective'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepNumber('02'),
          const SizedBox(height: 14),

          const Text(
            'Imagine a friend told you the same thing.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'What would your natural response be?',
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.65),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 26),

          ..._friendResponses.map(
                (item) {
              final selected =
                  _selectedFriendResponse == item['title'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildResponseCard(
                  title: item['title'],
                  icon: item['icon'],
                  selected: selected,
                  onTap: () {
                    setState(() {
                      _selectedFriendResponse = item['title'];
                      _friendResponseError = null;
                    });
                  },
                ),
              );
            },
          ),

          if (_friendResponseError != null) ...[
            const SizedBox(height: 2),
            _buildInlineError(_friendResponseError!),
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
  // STEP 3
  // ------------------------------------------------------------

  Widget _buildInnerCriticStep() {
    return SingleChildScrollView(
      key: const ValueKey('inner-critic'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepNumber('03'),
          const SizedBox(height: 14),

          const Text(
            'What does your inner critic say?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Write the thought exactly as it usually sounds in your head. You don’t have to agree with it.',
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.65),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 26),

          _buildTextArea(
            controller: _criticController,
            hint:
            'For example:\n\n“I should have done better.”\n\n“Everyone else is ahead of me.”\n\n“I always mess things up.”',
            error: _criticError,
            onChanged: () {
              if (_criticError != null) {
                setState(() {
                  _criticError = null;
                });
              }
            },
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE9E2D8),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💭',
                  style: TextStyle(fontSize: 23),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'A thought is something your mind produces. It does not automatically become a fact.',
                    style: TextStyle(
                      color: AppColors.navy.withOpacity(0.68),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
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
  // STEP 4
  // ------------------------------------------------------------

  Widget _buildKindResponseStep() {
    return SingleChildScrollView(
      key: const ValueKey('kind-response'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepNumber('04'),
          const SizedBox(height: 14),

          const Text(
            'Now answer yourself differently.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Use the same kindness you would offer someone you care about.',
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.65),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 26),

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
                const Icon(
                  Icons.favorite_border_rounded,
                  color: AppColors.mint,
                  size: 23,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'Try starting with: “It’s okay that…” or “I’m doing my best to…”',
                    style: TextStyle(
                      color: AppColors.navy.withOpacity(0.72),
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildTextArea(
            controller: _kindResponseController,
            hint:
            'Write something you would genuinely want to hear right now...',
            error: _kindResponseError,
            minLines: 7,
            maxLines: 11,
            onChanged: () {
              if (_kindResponseError != null) {
                setState(() {
                  _kindResponseError = null;
                });
              }
            },
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
  // STEP 5
  // ------------------------------------------------------------

  Widget _buildPermissionStep() {
    return SingleChildScrollView(
      key: const ValueKey('permission'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepNumber('05'),
          const SizedBox(height: 14),

          const Text(
            'What can you give yourself permission to do?',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Choose one small permission you want to carry with you after this exercise.',
            style: TextStyle(
              color: AppColors.navy.withOpacity(0.65),
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 26),

          ..._permissions.map(
                (item) {
              final selected =
                  _selectedPermission == item['title'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPermissionCard(
                  title: item['title'],
                  subtitle: item['subtitle'],
                  icon: item['icon'],
                  selected: selected,
                  onTap: () {
                    setState(() {
                      _selectedPermission = item['title'];
                      _permissionError = null;
                    });
                  },
                ),
              );
            },
          ),

          if (_permissionError != null) ...[
            const SizedBox(height: 2),
            _buildInlineError(_permissionError!),
          ],

          const SizedBox(height: 22),

          _buildBottomButton(
            text: 'Finish',
            onPressed: _finishExercise,
          ),
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
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: AppColors.lightMint,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.borderMint,
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.mint,
                    size: 42,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Center(
                child: Text(
                  'Compassion Pause Complete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 28,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'You paused the self-criticism and gave yourself a little more understanding.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy.withOpacity(0.65),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),

              const SizedBox(height: 30),

              _buildResultCard(
                icon: Icons.visibility_outlined,
                title: 'What you were being hard on yourself about',
                value: _situationController.text.trim(),
                multiline: true,
              ),

              const SizedBox(height: 12),

              _buildResultCard(
                icon: Icons.people_outline,
                title: 'How you would treat a friend',
                value: _selectedFriendResponse ?? 'Not selected',
              ),

              const SizedBox(height: 12),

              _buildResultCard(
                icon: Icons.psychology_outlined,
                title: 'What your inner critic said',
                value: _criticController.text.trim(),
                multiline: true,
              ),

              const SizedBox(height: 12),

              _buildResultCard(
                icon: Icons.favorite_border_rounded,
                title: 'Your kinder response',
                value: _kindResponseController.text.trim(),
                multiline: true,
              ),

              const SizedBox(height: 12),

              _buildResultCard(
                icon: Icons.self_improvement_outlined,
                title: 'Your permission',
                value: _selectedPermission ?? 'Not selected',
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
                    const Text(
                      '💚',
                      style: TextStyle(fontSize: 34),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'You deserve the same patience you give to others.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Being kind to yourself does not mean ignoring your responsibilities. It means facing them without unnecessary self-judgment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        fontSize: 13,
                        height: 1.55,
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
  // TEXT AREA
  // ------------------------------------------------------------

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hint,
    required String? error,
    required VoidCallback onChanged,
    int minLines = 8,
    int maxLines = 13,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: error != null
              ? Colors.red.shade300
              : AppColors.borderMint,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF9AA5AD),
            fontSize: 14,
            height: 1.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // RESPONSE CARD
  // ------------------------------------------------------------

  Widget _buildResponseCard({
    required String title,
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
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 10),

            _buildSelectionIndicator(selected),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PERMISSION CARD
  // ------------------------------------------------------------

  Widget _buildPermissionCard({
    required String title,
    required String subtitle,
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
              ),
            ),

            const SizedBox(width: 10),

            _buildSelectionIndicator(selected),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SELECTION INDICATOR
  // ------------------------------------------------------------

  Widget _buildSelectionIndicator(bool selected) {
    return AnimatedContainer(
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
  // GENTLE NOTE
  // ------------------------------------------------------------

  Widget _buildGentleNote({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderMint,
        ),
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
              style: TextStyle(
                color: AppColors.navy.withOpacity(0.65),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BUTTON
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