import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CalmGroundingScreen extends StatefulWidget {
  const CalmGroundingScreen({super.key});

  @override
  State<CalmGroundingScreen> createState() => _CalmGroundingScreenState();
}

class _CalmGroundingScreenState extends State<CalmGroundingScreen> {
  // ---------------------------------------------------------------------------
  // BREATHING
  // ---------------------------------------------------------------------------

  Timer? _breathingTimer;

  int _breathingSeconds = 60;
  bool _isBreathing = false;

  String _breathingPhase = 'Ready';
  double _breathingScale = 0.82;

  // ---------------------------------------------------------------------------
  // GROUNDING
  // ---------------------------------------------------------------------------

  final List<Map<String, dynamic>> _groundingSteps = [
    {
      'number': '5',
      'title': 'Notice 5 things you can see',
      'description':
      'Look around slowly and identify five things you can see around you.',
      'icon': Icons.visibility_outlined,
    },
    {
      'number': '4',
      'title': 'Notice 4 things you can touch',
      'description':
      'Notice four things you can physically feel, such as your chair, clothes, or phone.',
      'icon': Icons.touch_app_outlined,
    },
    {
      'number': '3',
      'title': 'Notice 3 things you can hear',
      'description':
      'Pause and identify three sounds around you.',
      'icon': Icons.hearing_outlined,
    },
    {
      'number': '2',
      'title': 'Notice 2 things you can smell',
      'description':
      'Notice two scents around you, even if they are very subtle.',
      'icon': Icons.air_outlined,
    },
    {
      'number': '1',
      'title': 'Notice 1 thing you can taste',
      'description':
      'Bring your attention to one taste in your mouth.',
      'icon': Icons.restaurant_outlined,
    },
  ];

  int _currentGroundingStep = 0;

  // ---------------------------------------------------------------------------
  // REFLECTION
  // ---------------------------------------------------------------------------

  final TextEditingController _reflectionController =
  TextEditingController();

  bool _completed = false;

  @override
  void dispose() {
    _breathingTimer?.cancel();
    _reflectionController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BREATHING LOGIC
  // ---------------------------------------------------------------------------

  void _startBreathing() {
    if (_isBreathing) return;

    setState(() {
      _isBreathing = true;
      _breathingSeconds = 60;
      _breathingPhase = 'Breathe in';
      _breathingScale = 1.12;
    });

    int phaseSeconds = 0;

    _breathingTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _breathingSeconds--;
          phaseSeconds++;

          if (phaseSeconds >= 4) {
            phaseSeconds = 0;

            if (_breathingPhase == 'Breathe in') {
              _breathingPhase = 'Hold';
              _breathingScale = 1.12;
            } else if (_breathingPhase == 'Hold') {
              _breathingPhase = 'Breathe out';
              _breathingScale = 0.82;
            } else {
              _breathingPhase = 'Breathe in';
              _breathingScale = 1.12;
            }
          }
        });

        if (_breathingSeconds <= 0) {
          timer.cancel();

          setState(() {
            _isBreathing = false;
            _breathingPhase = 'Complete';
            _breathingScale = 0.95;
          });
        }
      },
    );
  }

  void _resetBreathing() {
    _breathingTimer?.cancel();

    setState(() {
      _isBreathing = false;
      _breathingSeconds = 60;
      _breathingPhase = 'Ready';
      _breathingScale = 0.82;
    });
  }

  // ---------------------------------------------------------------------------
  // GROUNDING
  // ---------------------------------------------------------------------------

  void _nextGroundingStep() {
    if (_currentGroundingStep < _groundingSteps.length - 1) {
      setState(() {
        _currentGroundingStep++;
      });
    } else {
      setState(() {
        _completed = true;
      });

      _showCompletionDialog();
    }
  }

  void _previousGroundingStep() {
    if (_currentGroundingStep > 0) {
      setState(() {
        _currentGroundingStep--;
      });
    }
  }

  void _resetGrounding() {
    setState(() {
      _currentGroundingStep = 0;
      _completed = false;
    });
  }

  // ---------------------------------------------------------------------------
  // COMPLETION
  // ---------------------------------------------------------------------------

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.mint,
                size: 27,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Well done',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'You just gave yourself a moment to slow down and reconnect with the present.',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              height: 1.55,
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
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroCard(),

                    const SizedBox(height: 25),

                    _buildSectionHeader(
                      'Start with your breathing',
                      'Give yourself one quiet minute.',
                    ),

                    const SizedBox(height: 13),

                    _buildBreathingCard(),

                    const SizedBox(height: 28),

                    _buildSectionHeader(
                      'Ground yourself',
                      'Bring your attention back to the present moment.',
                    ),

                    const SizedBox(height: 13),

                    _buildGroundingCard(),

                    const SizedBox(height: 28),

                    _buildReflectionCard(),

                    const SizedBox(height: 22),

                    _buildMotivationCard(),

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

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(
                  color: AppColors.borderMint,
                ),
              ),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.navy,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calm & Ground',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'A small pause for a busy moment.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightMint,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              'RESET',
              style: TextStyle(
                color: AppColors.mint,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INTRO CARD
  // ---------------------------------------------------------------------------

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightMint,
            AppColors.lightMint.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.self_improvement_rounded,
              color: AppColors.mint,
              size: 29,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Let’s slow things down.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'You do not need to solve everything right now. Start with one small step.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 10.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION HEADER
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader(
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
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.navy.withValues(alpha: 0.52),
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BREATHING CARD
  // ---------------------------------------------------------------------------

  Widget _buildBreathingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
            width: 155 * _breathingScale,
            height: 155 * _breathingScale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.mint.withValues(alpha: 0.20),
                  AppColors.lightMint.withValues(alpha: 0.75),
                ],
              ),
              border: Border.all(
                color: AppColors.mint.withValues(alpha: 0.28),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _breathingPhase,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _isBreathing
                        ? '${_breathingSeconds}s'
                        : _breathingPhase == 'Complete'
                        ? 'Done'
                        : '60s',
                    style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.52),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            _isBreathing
                ? 'Follow the circle and keep your breathing slow.'
                : _breathingPhase == 'Complete'
                ? 'Take a moment to notice how you feel.'
                : 'Breathe slowly and comfortably. There is no need to force it.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.60),
              fontSize: 10.5,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 17),

          if (!_isBreathing && _breathingPhase != 'Complete')
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _startBreathing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  size: 21,
                ),
                label: const Text(
                  'Start 60-Second Breathing',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else if (_isBreathing)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: _resetBreathing,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  side: const BorderSide(
                    color: AppColors.borderMint,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Restart',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: _resetBreathing,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mint,
                  side: const BorderSide(
                    color: AppColors.borderMint,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 19,
                ),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GROUNDING CARD
  // ---------------------------------------------------------------------------

  Widget _buildGroundingCard() {
    final step = _groundingSteps[_currentGroundingStep];

    final double progress =
        (_currentGroundingStep + 1) / _groundingSteps.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderMint,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.spa_outlined,
                color: AppColors.mint,
                size: 21,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '5-4-3-2-1 Grounding',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${_currentGroundingStep + 1}/5',
                style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.45),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.lightMint,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.mint,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.lightMint.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.borderMint,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      step['number'] as String,
                      style: const TextStyle(
                        color: AppColors.mint,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  step['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  step['description'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.navy.withValues(alpha: 0.55),
                    fontSize: 10.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              if (_currentGroundingStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousGroundingStep,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(
                        color: AppColors.borderMint,
                      ),
                      minimumSize: const Size(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (_currentGroundingStep > 0)
                const SizedBox(width: 9),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextGroundingStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(
                    _currentGroundingStep ==
                        _groundingSteps.length - 1
                        ? 'Finish'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_completed) ...[
            const SizedBox(height: 11),
            Center(
              child: TextButton(
                onPressed: _resetGrounding,
                child: const Text(
                  'Start grounding again',
                  style: TextStyle(
                    color: AppColors.mint,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REFLECTION
  // ---------------------------------------------------------------------------

  Widget _buildReflectionCard() {
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
                  Icons.edit_note_rounded,
                  color: AppColors.mint,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What feels overwhelming?',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'You can write it down without judging yourself.',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _reflectionController,
            minLines: 4,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 11.5,
            ),
            decoration: InputDecoration(
              hintText:
              'For example: exams, workload, relationships, uncertainty...',
              hintStyle: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.35),
                fontSize: 10.5,
              ),
              filled: true,
              fillColor: AppColors.lightMint.withValues(alpha: 0.35),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: AppColors.borderMint,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: AppColors.borderMint,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: AppColors.mint,
                  width: 1.2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'This reflection stays on this screen for now.',
            style: TextStyle(
              color: AppColors.navy.withValues(alpha: 0.38),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOTIVATION
  // ---------------------------------------------------------------------------

  Widget _buildMotivationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.mint,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A gentle reminder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'You do not have to figure everything out today. '
                      'One small step is still progress.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
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

  // ---------------------------------------------------------------------------
  // SAFETY NOTE
  // ---------------------------------------------------------------------------

  Widget _buildSafetyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.navy.withValues(alpha: 0.45),
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'These exercises are general wellbeing tools and are not a substitute for professional mental-health care. If you feel unsafe or are in immediate danger, seek appropriate emergency support.',
              style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.50),
                fontSize: 9.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}